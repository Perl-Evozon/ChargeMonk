package Chargemonk::Controller::User::Profile;

use Moose;
use namespace::autoclean;
use Try::Tiny;

BEGIN { extends 'Chargemonk::Controller::Authenticated'; }

=head1 NAME

Chargemonk::Controller::User::Profile - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 auto

Forward the current subscription actions to the subscription actions controller.

=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    my $subscription_actions_dispatcher = {cancel_subscription => '/common/subscriptionactions/cancel_subscription',};
    foreach ( keys %$subscription_actions_dispatcher ) {
        $c->forward( $subscription_actions_dispatcher->{$_} ) if ( defined $c->req->param($_) );
    }

    return 1;
}


=head2 profile

Controller for user 'Profile' page

=cut


sub profile : Path : Args(0) {
    my ( $self, $c ) = @_;

    if ( $c->req->param('no_rights') ) {
        $c->alert( {'error' => 'Cannot change subsciption for another user'} );
    }

    my $user                 = $c->user;
    my $current_subscription = $c->model('Chargemonk::LinkUserSubscription')
        ->search_rs( {user_id => $c->user->id, active => '1'}, {prefetch => 'subscription'} )->first;

    my $active_subscriptions = $c->model('Chargemonk::LinkUserSubscription')->search_rs(
        {   user_id => $user->id,
            -or     => [active => '1', cancelled => '0']
        }
    )->count;

    my @billing_history = $c->model('Chargemonk::LinkUserSubscription')->search_rs(
        {"me.user_id" => $user->id,},
        {   prefetch => ['invoices', 'subscription'],
            order_by => {-desc => 'me.id'}
        }
    )->all;

    my ( $upgrades_to, $downgrades_to, $renew );

    if ($current_subscription) {

        if ( $active_subscriptions < 2 ) {
            $upgrades_to = $c->model('Chargemonk::SubscriptionUpgradeTo')
                ->search_rs( {'subscription_id' => $current_subscription->subscription->id} )->all;
            $downgrades_to = $c->model('Chargemonk::SubscriptionDowngradeTo')
                ->search_rs( {'subscription_id' => $current_subscription->subscription->id} )->all;
        }

    }
    elsif ( scalar(@billing_history) ) {
        $renew = 1;
    }

    $c->stash(
        {   user                 => $user,
            current_subscription => $current_subscription,
            upgrades_to          => $upgrades_to,
            renew                => $renew,
            downgrades_to        => $downgrades_to,
            billing_history      => \@billing_history,
        }
    );
}

=head2 edit_user

Controller for admin 'Edit User' page

=cut

sub edit_profile : Local('edit_profile') : Args(0) {
    my ( $self, $c ) = @_;

    if ( !$c->req->param ) {
        $c->go('/');
        $c->detach();
    }

    my $user = $c->model('Chargemonk::User')->find( $c->user->id );

    my @cols = qw(
        firstname lastname address address2 country state zip_code phone gender
        birthday company_name company_address company_country
        company_state company_zip_code company_phone
    );
    my $user_hash;
    map { $user_hash->{$_} = $c->req->param($_) || undef } @cols;

    try {
        $user->update($user_hash);

        $c->alert( {'success' => 'The user was successfuly edited.'} );
    
        $c->forward( '/common/user/_save_photo', [$user] ) if ( $c->req->param('photo_input') );
    
        #refresh from storage
        $user->discard_changes;

        $c->stash( {user => $user} );
    }
    catch {
        $c->alert( {'error' => 'Unable to edit user info. Please check the error log for more details.'}, $_ );
        return;
    } or return;
}


=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') { }

=head1 AUTHOR

mar_k

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
