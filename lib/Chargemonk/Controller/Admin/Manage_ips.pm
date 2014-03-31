package Chargemonk::Controller::Admin::Manage_ips;

use Moose;
use namespace::autoclean;
use Try::Tiny;

BEGIN { extends 'Chargemonk::Controller::Authenticated'; }

=head1 NAME

Chargemonk::Controller::Admin::Manage_ips - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub manage_ips : Path : Args() {
	my ( $self, $c ) = @_;
	my @alerts = ();

	my $user = $c->model('Chargemonk::User')->find( $c->req->args->[0] );

	my @link_user_subscriptions = $c->model('Chargemonk::LinkUserSubscription')->search(
		{   user_id                    => $user->id,
			'subscription.access_type' => 'IP_range'
		},
		{join => 'subscription'}
	)->all;

	my $link_user_subscriptions;
	if ( $c->req->param('subscription_id') ) {
		$link_user_subscriptions =
			$c->model('Chargemonk::LinkUserSubscription')->search( {subscription_id => $c->req->param('subscription_id')} )
			->single;
	}
	else {
		$link_user_subscriptions = $link_user_subscriptions[0];
	}

	#check if the user wants to add a new ip_range
	$self->add_ip_range( $c, \@alerts, $user, $link_user_subscriptions )
		if ( defined $c->req->param('submit_add_ip_range_form') );

	#check if the user wants to edit a new ip_range
	$self->edit_ip_range( $c, \@alerts, $user, $link_user_subscriptions )
		if ( defined $c->req->param('submit_edit_ip_range_form') || defined $c->req->args->[1] );

	my @ip_ranges;
	try {
		@ip_ranges = $link_user_subscriptions->ip_ranges->all;
	}
	catch {
		$c->alert( {'error' => 'There was an error fetching the IPs'} );
		$c->logger->error( 'Cannot fetch ips: ' . $_ );
	};

	$c->stash(
		{   user                    => $user,
			ip_ranges               => \@ip_ranges,
			total_ip_ranges         => scalar @ip_ranges,
			simulate_modal          => $c->req->param('simulate_modal') || 0,
			alerts                  => \@alerts,
			link_user_subscriptions => \@link_user_subscriptions,
		}
	);

}

=haed2 check_ip_range

Method for validating 2 IP Ranges

=cut

sub check_ip_range {
	my ( $self, $from_ip, $to_ip ) = @_;

	my $from = new Net::IP($from_ip) or return 0;
	my $to   = new Net::IP($to_ip)   or return 0;

	my @from_ip_bytes = split( '\.', $from->ip );
	my @to_ip_bytes   = split( '\.', $to->ip );

	my $from_ip_class = $from_ip_bytes[0] . $from_ip_bytes[1] . $from_ip_bytes[2];
	my $to_ip_class   = $to_ip_bytes[0] . $to_ip_bytes[1] . $to_ip_bytes[2];

	return 0 if ( $from_ip_class ne $to_ip_class );

	return 0 if ( $from_ip_bytes[3] >= $to_ip_bytes[3] );

	return 1;
}

=head2 add_ip_range

Method for adding a new IP range

=cut

sub add_ip_range {
	my ( $self, $c, $alerts, $user, $link_user_subscription ) = @_;

	my $from_ip = $c->req->param('from_ip');
	my $to_ip   = $c->req->param('to_ip_class') . '.' . $c->req->param('to_ip_last_byte');

	#checks if the IP Range is valid or if the IP is a valid IPv4 IP address
	if ( not $self->check_ip_range( $from_ip, $to_ip ) ) {
		push( @{$alerts}, {'error' => 'Invalid IP or IP Range'} );
		$c->logger->error( 'Invalid IP or IP Range: ' . $from_ip . " " . $to_ip );

		return;
	}

	try {
		$c->model('Chargemonk::IpRange')->create(
			{   link_user_subscription_id => $link_user_subscription->id,
				subscription_id           => $link_user_subscription->subscription_id,
				from_ip                   => $from_ip,
				to_ip                     => $to_ip,
				status                    => $c->req->param('activated')
			}
		);
		$c->alert( {'success' => 'The ip range was successfully added.'} );
	}
	catch {
		$c->alert( {'error' => 'Cannot create the ip range. Please check the logger for more information.' . $_} );
		$c->logger->error( 'Cannot create IP range: ' . $_ );
		return;
	} or return;
}

=head2 edit_ip_range

Method for editing an IP range

=cut

sub edit_ip_range {
	my ( $self, $c, $alerts, $user, $link_user_subscription ) = @_;

	my $ip_range;
	try {
		$ip_range = $link_user_subscription->ip_ranges->find( $c->req->args->[1] );
	}
	catch {
		$c->alert( {'error' => 'There was an error while fetching the IP Range you have requested.'} );
		$c->logger->error( 'Cannot fetch IP Range: ' . $_ );
	};

	$c->stash(
		{   ip_range            => $ip_range,
			simulate_modal_edit => defined( $c->req->param('simulate_modal_edit') )
			? $c->req->param('simulate_modal_edit')
			: 1
		}
	);

	#check if the user submited the edit form
	return unless ( defined $c->req->param('submit_edit_ip_range_form') );

	my $from_ip = $c->req->param('from_ip');
	my $to_ip   = $c->req->param('to_ip_class') . '.' . $c->req->param('to_ip_last_byte');

	#checks if the IP Range is valid or if the IP is a valid IPv4 IP address
	if ( !$self->check_ip_range( $from_ip, $to_ip ) ) {
		push( @{$alerts}, {'error' => 'Invalid IP or IP Range'} );
		$c->logger->error( 'Invalid IP or IP Range: ' . $from_ip . " " . $to_ip );

		return;
	}
	try {
		$ip_range->update( {from_ip => $from_ip, to_ip => $to_ip, status => $c->req->param('activated')} );
	}
	catch {
		$c->alert( {'error' => 'Unable to update the IP Range, please make sure that the data is entered correctly.'} );
		$c->logger->error( 'Cannot fetch Period user: ' . $_ );
		return;
	} or return;

	$c->alert( {'success' => 'The IP Range was successfully updated.'} );
	$c->logger->info( 'IP Range updated with the id: ' . $ip_range->id );

	$c->stash( {ip_range => $ip_range} );
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') { }

=head1 AUTHOR

Andrei,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
