package SubMan::Controller::Common::SubscriptionActions;

use Moose;
use namespace::autoclean;
use Module::Load;
use DateTime::Format::Pg;
use DateTime;
use URI;
use Try::Tiny;

use SubMan::Helpers::Gateways::Details;
use SubMan::Helpers::Gateways::Authorize;
use SubMan::Helpers::Gateways::Braintree;
use SubMan::Helpers::Gateways::Stripe;
use SubMan::Common::Logger qw($logger);

BEGIN { extends 'SubMan::Controller::Authenticated'; }

=head1 NAME

SubMan::Controller::Common::SubscriptionActions - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto

sets the wrapper for the template files so we can call this controller
either as an admin or as a simple user.

=cut

sub auto : Private {
	my ( $self, $c ) = @_;

	my $wrapper;

	if   ( $c->user->user_type eq 'ADMIN' ) { $wrapper = 'layouts/admin.tt' }
	else                               { $wrapper = 'layouts/user.tt'; }

	$c->stash( {wrapper => $wrapper} );

	if ( $c->user->user_type ne 'ADMIN' ) {
		if ( $c->req->args->[0] && ( $c->req->args->[0] != $c->user->id ) ) {
			$c->response->redirect( $c->uri_for( "/user/profile", {no_rights => 1} ) );
			return;
		}
	}


	return 1;
}


=head2 cancel_subscription

Cancel current subscription

=cut

sub cancel_subscription : Local {
	my ( $self, $c ) = @_;

	# the admin wants to cancel the current active subscription for a user

	my $link_user_subscription_row =
		$c->model('SubMan::LinkUserSubscription')->find( $c->req->param('link_user_subscription_id') );

	if ($link_user_subscription_row) {
		if ( $link_user_subscription_row->cancelled ) {

			# the subscription is already cancelled
			$c->alert( {'info' => 'The active subscription for this user was already cancelled.'},
				"id: " . $c->req->param('link_user_subscription_id') );
		}
		else {
			# cancel the subscription
			$link_user_subscription_row->update( {cancelled => 1} );
			$c->alert( {'success' => 'The current subscription for this user was cancelled.'},
				"id: " . $c->req->param('link_user_subscription_id') );
		}
	}
	else {
		$c->alert( {'error' => 'Could not find the current subscription for this user.'},
			$c->req->param('link_user_subscription_id') );
	}

}


=head2 upgrade_choose

first step for upgrade subscription where we choose the subscription to upgrade to

=cut

sub upgrade_choose : Local : Args(2) {
	my ( $self, $c ) = @_;

	my $user_id              = $c->req->args->[0];
	my $link_subscription_id = $c->req->args->[1];

	my $link_subscription = $c->model('SubMan::LinkUserSubscription')->find($link_subscription_id);

	my @upgrades_to =
		$c->model('SubMan::SubscriptionUpgradeTo')
		->search_rs( {'subscription_id' => $link_subscription->subscription_id}, {prefetch => 'subscription_upgrade'} )
		->all;

	$c->stash( {subscriptions => \@upgrades_to} );

	return;
}

=head2 upgrade

secound step for upgrade subscription where we calculate the price of the subscription

=cut

sub upgrade : Local : Args(2) {
	my ( $self, $c ) = @_;

	if ( !$c->req->param('subscription') ) {
		$c->response->redirect(
			'/common/subscriptionactions/upgrade_choose/' . $c->req->args->[0] . '/' . $c->req->args->[1] );
		return;
	}

	my $user_id              = $c->req->args->[0];
	my $link_subscription_id = $c->req->args->[1];

	my $new_subscription = $c->model('SubMan::Subscription')->find( $c->req->param('subscription') );

	my $link_subscription =
		$c->model('SubMan::LinkUserSubscription')->find( $link_subscription_id, {prefetch => 'subscription'} );

	my $parser     = DateTime::Format::Pg->new();
	my $dt         = DateTime->now;
	my $start_date = $parser->format_datetime($dt);
	my $end_date   = $parser->format_datetime( $dt->clone->add( days => $new_subscription->period ) );
	my $reminder   = $self->calculate_reminder( $c, $link_subscription );

	my $final_payment_amount = $new_subscription->price - $reminder->{'remaining_amount'};

	$c->stash(
		{   current_subscription        => $link_subscription,
			new_subscription_name       => $new_subscription->name,
			new_subscription_price      => $new_subscription->price,
			new_subscription_start_date => $start_date,
			new_subscription_end_date   => $end_date,
			new_subscription_id         => $c->req->param('subscription'),
			remaining_days              => $reminder->{'remaining_days'},
			remaining_amount            => $reminder->{'remaining_amount'},
			final_price                 => $final_payment_amount
		}
	);

}

=head2 upgrade_save

last step for cancel subscription where we save the subscription

=cut

sub upgrade_save : Local : Args(2) {
	my ( $self, $c ) = @_;

	unless ( $c->req->param('subscription') ) {
		$c->response->redirect(
			'/common/subscriptionactions/upgrade_choose/' . $c->req->args->[0] . '/' . $c->req->args->[1] );
		return;
	}

	my $user_id              = $c->req->args->[0];
	my $link_subscription_id = $c->req->args->[1];

	$c->stash(
		{   template => 'common/subscriptionactions/result.tt',
			user_id  => $user_id
		}
	);

	my $new_subscription = $c->model('SubMan::Subscription')->find( $c->req->param('subscription') );

	my $link_subscription =
		$c->model('SubMan::LinkUserSubscription')->find( $link_subscription_id, {prefetch => 'subscription'} );

	my $parser     = DateTime::Format::Pg->new();
	my $dt         = DateTime->now;
	my $start_date = $parser->format_datetime($dt);
	my $end_date   = $parser->format_datetime( $dt->clone->add( days => $new_subscription->period ) );
	my $reminder   = $self->calculate_reminder( $c, $link_subscription );

	my $final_payment_amount = $new_subscription->price - $reminder->{'remaining_amount'};

	my $new_link_user_subscription;

	try {
		$new_link_user_subscription = $c->model('SubMan::LinkUserSubscription')->create(
			{   user_id            => $user_id,
				subscription_id    => $new_subscription->id,
				nr_of_period_users => 1,
				active_from_date   => $start_date,
				active_to_date     => $end_date,
				active             => 0,
			}
		);
	}
	catch {
		$c->alert(
			{'error' => 'Unable to create subscription. Please check the error log for more details.'},
			"subscription:" . $new_subscription->id . " | user: $user_id error: $_"
		);
		return;
	} or return;


	my $gateway = SubMan::Helpers::Gateways::Details::get_active_gateway;
	my $gateway_credentials = SubMan::Helpers::Gateways::Details::get_gateway_credentials( $c, $gateway );

	$gateway = 'SubMan::Helpers::Gateways::' . ucfirst($gateway);
	my $active_gateway = $gateway->new(
		args => {
			c                         => $c,
			gateway_credentials       => $gateway_credentials,
			link_user_subscription_id => $new_link_user_subscription->id,
			amount                    => $final_payment_amount
		}
	);
	$active_gateway->pay();

	if ( !$c->has_errors() ) {
		$link_subscription->update( {active => 0} );
		$new_link_user_subscription->update( {active => 1} );
		$c->alert( {'success' => 'Payment completed successfully for link subscription:'.$new_link_user_subscription->id() } );
	}
	else {
		$new_link_user_subscription->delete();
	}

	return;
}

=head2 downgrade_choose

first step for downgrade subscription where we choose the subscription to upgrade to

=cut

sub downgrade_choose : Local : Args(2) {
	my ( $self, $c ) = @_;

	my $user_id              = $c->req->args->[0];
	my $link_subscription_id = $c->req->args->[1];

	my $link_subscription = $c->model('SubMan::LinkUserSubscription')->find($link_subscription_id);

	my @downgrades_to =
		$c->model('SubMan::SubscriptionDowngradeTo')
		->search_rs( {'subscription_id' => $link_subscription->subscription_id},
		{prefetch => 'subscription_downgrade'} )->all;

	$c->stash( {subscriptions => \@downgrades_to} );

	return;
}

=head2 downgrade

secound step for downgrade subscription where we calculate the price of the subscription

=cut

sub downgrade : Local : Args(2) {
	my ( $self, $c ) = @_;

	if ( !$c->req->param('subscription') ) {
		$c->response->redirect(
			'/common/subscriptionactions/downgrade_choose/' . $c->req->args->[0] . '/' . $c->req->args->[1] );
		return;
	}

	my $user_id              = $c->req->args->[0];
	my $link_subscription_id = $c->req->args->[1];

	my $new_subscription = $c->model('SubMan::Subscription')->find( $c->req->param('subscription') );

	my $link_subscription =
		$c->model('SubMan::LinkUserSubscription')->find( $link_subscription_id, {prefetch => 'subscription'} );

	my $parser              = DateTime::Format::Pg->new();
	my $start_date_datetime = $parser->parse_datetime( $link_subscription->active_to_date )->add( days => 1 );
	my $start_date          = $parser->format_datetime($start_date_datetime);
	my $end_date = $parser->format_datetime( $start_date_datetime->clone->add( days => $new_subscription->period ) );

	$c->stash(
		{   current_subscription        => $link_subscription,
			new_subscription_name       => $new_subscription->name,
			new_subscription_price      => $new_subscription->price,
			new_subscription_start_date => $start_date,
			new_subscription_end_date   => $end_date,
			new_subscription_id         => $c->req->param('subscription')
		}
	);
}

=head2 downgrade_save

last step for downgrade_save subscription where we save the subscription

=cut

sub downgrade_save : Local : Args(2) {
	my ( $self, $c ) = @_;

	unless ( $c->req->param('subscription') ) {
		$c->response->redirect(
			'/common/subscriptionactions/downgrade_choose/' . $c->req->args->[0] . '/' . $c->req->args->[1] );
		return;
	}

	my $user_id              = $c->req->args->[0];
	my $link_subscription_id = $c->req->args->[1];

	$c->stash(
		{   template => 'common/subscriptionactions/result.tt',
			user_id  => $user_id
		}
	);

	my $new_subscription = $c->model('SubMan::Subscription')->find( $c->req->param('subscription') );

	my $link_subscription =
		$c->model('SubMan::LinkUserSubscription')->find( $link_subscription_id, {prefetch => 'subscription'} );

	my $parser              = DateTime::Format::Pg->new();
	my $start_date_datetime = $parser->parse_datetime( $link_subscription->active_to_date )->add( days => 1 );
	my $start_date          = $parser->format_datetime($start_date_datetime);
	my $end_date = $parser->format_datetime( $start_date_datetime->clone->add( days => $new_subscription->period ) );

	my $new_link_user_subscription;

	try {
		$new_link_user_subscription = $c->model('SubMan::LinkUserSubscription')->create(
			{   user_id            => $user_id,
				subscription_id    => $new_subscription->id,
				nr_of_period_users => 1,
				active_from_date   => $start_date,
				active_to_date     => $end_date,
				active             => 0,
			}
		);
	}
	catch {
		$c->alert( {'error' => 'Unable to create subscription. Please check the error log for more details.'},
			"subscription id: " . $new_subscription->id() . " | error: $_" );
		return;
	} or return;

	$c->alert(
		{'success' => 'Subscription saved successfully. Payment will de done when the current subscription ends'},
		"subscription id: " . $new_subscription->id() );

	return;
}

=head2 renew

first step for renew subscription where we choose the subscription to upgrade to

=cut

sub renew : Local : Args(2) {
	my ( $self, $c ) = @_;

	my $user_id         = $c->req->args->[0];
	my $subscription_id = $c->req->args->[1];

	my $new_subscription = $c->model('SubMan::Subscription')->find($subscription_id);

	my $parser     = DateTime::Format::Pg->new();
	my $dt         = DateTime->now;
	my $start_date = $parser->format_datetime($dt);
	my $end_date   = $parser->format_datetime( $dt->clone->add( days => $new_subscription->period ) );

	$c->stash(
		{   new_subscription_name       => $new_subscription->name,
			new_subscription_price      => $new_subscription->price,
			new_subscription_start_date => $start_date,
			new_subscription_end_date   => $end_date,
			final_price                 => $new_subscription->price,
			wrapper                     => "layouts/user.tt"
		}
	);
}

=head2 renew

last step for renew subscription where we save the subscription

=cut

sub renew_save : Local : Args(2) {
	my ( $self, $c ) = @_;

	my $user_id         = $c->req->args->[0];
	my $subscription_id = $c->req->args->[1];

	$c->stash(
		{   template => 'common/subscriptionactions/result.tt',
			user_id  => $user_id
		}
	);

	my $new_subscription = $c->model('SubMan::Subscription')->find($subscription_id);

	my $parser     = DateTime::Format::Pg->new();
	my $dt         = DateTime->now;
	my $start_date = $parser->format_datetime($dt);
	my $end_date   = $parser->format_datetime( $dt->clone->add( days => $new_subscription->period ) );

	my $new_link_user_subscription;

	try {
		$new_link_user_subscription = $c->model('SubMan::LinkUserSubscription')->create(
			{   user_id         => $user_id,
				subscription_id => $new_subscription->id,

				#            to be changed from interface
				nr_of_period_users => 1,
				active_from_date   => $start_date,
				active_to_date     => $end_date,
				active             => 0,
			}
		);
	}
	catch {
		$c->alert( {'error' => 'Unable to create subscription. Please check the error log for more details.'},
			"subscription_id: " . $new_subscription->id() . " | error: $_" );
		return;
	} or return;


	my $gateway = SubMan::Helpers::Gateways::Details::get_active_gateway;
	my $gateway_credentials = SubMan::Helpers::Gateways::Details::get_gateway_credentials( $c, $gateway );

	$gateway = 'SubMan::Helpers::Gateways::' . ucfirst($gateway);

	my $active_gateway = $gateway->new(
		args => {
			c                         => $c,
			gateway_credentials       => $gateway_credentials,
			link_user_subscription_id => $new_link_user_subscription->id,
			amount                    => $new_link_user_subscription->amount_with_discount()
				|| $new_link_user_subscription->subscription->price(),
		}
	);
	$active_gateway->pay();

	if ( !$c->has_errors() ) {
		$new_link_user_subscription->update( {active => 1} );
		$c->alert( {'success' => 'Payment completed successfully for link subscription:'.$new_link_user_subscription->id()} );
	}
	else {
		$new_link_user_subscription->delete();
	}

	return;

}

=head2 calculate_reminder

helper method that calculates what remains from the previous subscription

=cut

sub calculate_reminder : Private {
	my ( $self, $c, $link_subscription ) = @_;

	my $result = {};
	my $dt     = DateTime->now;
	my $parser = DateTime::Format::Pg->new();

	my $end_date = $parser->parse_datetime( $link_subscription->active_to_date );
	$result->{'remaining_days'} = $dt->delta_days($end_date)->in_units('days');
	$result->{'remaining_amount'} = int( ( $link_subscription->subscription->price * $result->{'remaining_days'} )
		/ $link_subscription->subscription->period );

	return $result;
}


=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') { }

=head1 AUTHOR

MeSe

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
