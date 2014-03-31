package Chargemonk::Controller::Admin::Subscriptions::edit_subscription;
use Moose;
use namespace::autoclean;
use List::MoreUtils qw(zip uniq);
BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Chargemonk::Controller::Admin::Subscriptions::edit_subscription - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 features_tab

    Load features tab for selected group

=cut

sub features_tab : Local : Args(2) {
    my ( $self, $c ) = @_;

    my $subscription = $c->model('Chargemonk::Subscription')->find( {id => $c->req->args->[0]} );
    my $group = $c->model('Chargemonk::SubscriptionGroup')->find( {id => $c->req->args->[1]} );

    my @groups   = $c->model('Chargemonk::SubscriptionGroup')->all();
    my @features = $c->model('Chargemonk::Feature')->all();

    my @reload_features = split ',', $c->req->params->{reload_features};
    my @reload_subscription_features =
        $c->model('Chargemonk::LinkSubscriptionFeature')
        ->search( {subscription_id => $c->req->params->{reload_subscription_features}} )->all()
        if ( $c->req->params->{reload_subscription_features} );
    @reload_subscription_features = map { $_->feature_id } @reload_subscription_features
        if (@reload_subscription_features);
    my @new_features_ids = grep { defined $_ && $_ ne '' } zip( @reload_features, @reload_subscription_features );

    my @current_features_ids =
        ( scalar @new_features_ids )
        ? @new_features_ids
        : map { $_->id }
        $c->model('Chargemonk::Feature')
        ->search( {subscription_id => $subscription->id}, {join => 'link_subscription_feature'} )->all();

    my @subscriptions = $c->model('Chargemonk::Subscription')->search(
        {   id                    => {'!=' => $subscription->id},
            subscription_group_id => $group->id
        }
    )->all();

    my @link_subscriptions_features = $c->model('Chargemonk::LinkSubscriptionFeature')->all();

    $c->stash(
        {   current_subscription        => $subscription,
            subscriptions               => \@subscriptions,
            features                    => \@features,
            current_features_ids        => \@current_features_ids,
            link_subscriptions_features => \@link_subscriptions_features,
            current_group               => $c->req->args->[1]
        }
    );
}

=head2 group_tab

    Load group tab for selected group

=cut

sub group_tab : Local : Args(2) {
    my ( $self, $c ) = @_;

    my $subscription = $c->model('Chargemonk::Subscription')->find( {id => $c->req->args->[0]} );

    my $group = $c->model('Chargemonk::SubscriptionGroup')->find( {id => $c->req->args->[1]} );

    my @subscriptions = $c->model('Chargemonk::Subscription')->search( {subscription_group_id => $group->id} )->all();

    my @reloaded_subscriptions = split /\|/, $c->req->params->{reload_groups} if ( $c->req->params->{reload_groups} );

    my @ordered_groups = ();

    foreach ( grep { defined } @reloaded_subscriptions ) {
        my $subscription_order = ( split /\_\_/, $_ )[0] || '';
        my $subscription_name  = ( split /\_\_/, $_ )[1] || '';
        push @ordered_groups,
            {
            subscription_name  => $subscription_name,
            subscription_order => $subscription_order,
            current            => $subscription_name eq "... (this subscription)" ? 1 : 0
            };
    }

    $c->stash(
        {   current_subscription    => $subscription,
            reloaded_ordered_groups => [sort { $a->{subscription_order} <=> $b->{subscription_order} } @ordered_groups],
            subscriptions           => \@subscriptions,
            current_group           => $c->req->args->[1]
        }
    );
}

=head2 upgrade_tab

    Load upgrade tab for selected group

=cut

sub upgrade_tab : Local : Args(2) {
    my ( $self, $c ) = @_;

    my $subscription = $c->model('Chargemonk::Subscription')->find( {id => $c->req->args->[0]} );

    my $group = $c->model('Chargemonk::SubscriptionGroup')->find( {id => $c->req->args->[1]} );

    my @subscriptions = $c->model('Chargemonk::Subscription')->search( {subscription_group_id => $group->id} )->all();

    my @subscription_upgrade_to_ids =
        ( $c->req->params->{reload_upgrades} )
        ? split ",", $c->req->params->{reload_upgrades}
        : map { $_->subscription_upgrade_id }
        $c->model('Chargemonk::SubscriptionUpgradeTo')->search( {subscription_id => $subscription->id} )->all;

    $c->stash(
        {   current_subscription        => $subscription,
            subscription_upgrade_to_ids => \@subscription_upgrade_to_ids,
            subscriptions               => \@subscriptions,
            current_group               => $c->req->args->[1]
        }
    );
}

=head2 downgrade_tab

    Load downgrade tab for selected group

=cut

sub downgrade_tab : Local : Args(2) {
    my ( $self, $c ) = @_;

    my $subscription = $c->model('Chargemonk::Subscription')->find( {id => $c->req->args->[0]} );

    my $group = $c->model('Chargemonk::SubscriptionGroup')->find( {id => $c->req->args->[1]} );

    my @subscriptions = $c->model('Chargemonk::Subscription')->search( {subscription_group_id => $group->id} )->all();

    my @subscription_downgrade_to_ids =
        ( $c->req->params->{reload_downgrades} )
        ? split ",", $c->req->params->{reload_downgrades}
        : map { $_->subscription_downgrade_id }
        $c->model('Chargemonk::SubscriptionDowngradeTo')->search( {subscription_id => $subscription->id} )->all;

    $c->stash(
        {   current_subscription          => $subscription,
            subscription_downgrade_to_ids => \@subscription_downgrade_to_ids,
            subscriptions                 => \@subscriptions,
            current_group                 => $c->req->args->[1]
        }
    );
}

=head1 AUTHOR

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
