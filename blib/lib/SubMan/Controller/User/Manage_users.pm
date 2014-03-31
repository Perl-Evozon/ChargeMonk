package SubMan::Controller::User::Manage_users;

use Moose;
use namespace::autoclean;
use Try::Tiny;

BEGIN { extends 'SubMan::Controller::Authenticated'; }

=head1 NAME

SubMan::Controller::User::Manage_users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 manage_users

Controller for 'Manage Users' page, for users

=cut

=head2 manage_uses

Controller for managing period users for PeriodUser type subscription

=cut

sub manage_users : Path : Args() {
	my ( $self, $c ) = @_;

	my $user = $c->model('SubMan::User')->find( $c->user->id() );
	$c->session->{manage_user}->{id} = $c->user->id();

	my @link_user_subscriptions = $c->model('SubMan::LinkUserSubscription')->search(
		{   user_id                    => $user->id,
			'subscription.access_type' => 'period_users'
		},
		{join => 'subscription'}
	)->all;

	my $link_user_subscriptions;
	if ( $c->req->param('subscription_id') ) {
		$link_user_subscriptions =
			$c->model('SubMan::LinkUserSubscription')->search( {subscription_id => $c->req->param('subscription_id')} )
			->single;
	}
	else {
		$link_user_subscriptions = $link_user_subscriptions[0];
	}

	#see if the admin/user wants to add a new period user
	$self->add_period_user( $c, $user, $link_user_subscriptions )
		if ( defined $c->req->param('submit_add_user_form') );

	#see if the admin/user wants to edit a new period user
	$self->edit_period_user( $c, $user, $link_user_subscriptions )
		if ( defined $c->req->param('submit_edit_user_form') || defined $c->req->args->[0] );

	my @period_users;
	try {
		@period_users = $link_user_subscriptions->period_users->all;
	}
	catch {
		$c->alert( {'error' => 'There was an error fetching the period users'}, $_ );
	};

	if ( !$user->has_period_users_subscription ) {
		$c->alert( {'error' => 'User doesn\'t have a Period user subscription'} );
	}

	$c->stash(
		{   user                    => $user,
			period_users            => \@period_users,
			total_period_users      => scalar @period_users,
			simulate_modal          => $c->req->param('simulate_modal') || 0,
			link_user_subscriptions => \@link_user_subscriptions,
		}
	);
}

=head2 can_be_activated

Function to check if the user can be activated on the subscription

=cut

sub can_be_activated {
	my ( $self, $c, $user, $link_user_subscription ) = @_;

	my $total_period_users = $link_user_subscription->period_users->search( {status => 1} )->count;

	#check to see if there is sapce for another activated user in the subscription
	if ( $link_user_subscription->nr_of_period_users <= $total_period_users ) {
		$c->alert(
			{   'error' =>
					'Cannot create the period user. You have reached the limit of period users for this subscription'
			},
			"link_subscription_id:" . $link_user_subscription->id()
		);

		return 0;
	}

	return 1;
}


=head2 add_period_user

Action for adding a new period user

=cut

sub add_period_user {
	my ( $self, $c, $user, $link_user_subscription ) = @_;

	#check to see if there is space for another activated user in the subscription
	if ( $c->req->param('activated') ) {
		return 0 unless ( $self->can_be_activated( $c, $user, $link_user_subscription ) );
	}

	try {
		$c->model('SubMan::PeriodUser')->create(
			{   link_user_subscription_id => $link_user_subscription->id,
				subscription_id           => $link_user_subscription->subscription_id,
				first_name                => $c->req->param('first_name'),
				last_name                 => $c->req->param('last_name'),
				email                     => $c->req->param('email'),
				status                    => $c->req->param('activated')
			}
		);

		$c->alert( {'success' => 'The period user was successfully added.'},
			"period user: " . $c->req->param('email') . " subscription_id:" . $c->req->param('subscription_id') );

	}
	catch {
		$c->alert( {'error' => 'Cannot create the period user. Please check the logger for more information.' . $_} );
		return;
	} or return;

	return 1;
}

=head2 edit_period_user

Action for editing a period user for a specific subscription

=cut

sub edit_period_user {
	my ( $self, $c, $user, $link_user_subscription ) = @_;

	my $period_user;
	try {
		$period_user = $link_user_subscription->period_users->find( $c->req->args->[1] );
	}
	catch {
		$c->alert( {'error' => 'There was an error while fetching the period user you have requested.'}, $_ );
	};

	$c->stash(
		{   period_user         => $period_user,
			simulate_modal_edit => defined( $c->req->param('simulate_modal_edit') )
			? $c->req->param('simulate_modal_edit')
			: 1
		}
	);

	#check to see if the admin/user submited the edit form
	return unless ( defined $c->req->param('submit_edit_user_form') );

	try {
		$period_user->update(
			{   first_name => $c->req->param('first_name'),
				last_name  => $c->req->param('last_name'),
				email      => $c->req->param('email'),
				status     => $c->req->param('activated')
			}
		);

		$c->alert( {'success' => 'The period user was successfully updated.'}, "period user id:" . $period_user->id() );

		$c->stash( {period_user => $period_user} );
	}
	catch {
		$c->alert(
			{'error' => 'Unable to update the period user, please make sure that the data is entered correctly.'},
			'Cannot fetch Period user: ' . $_ );
		return;
	} or return;
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
