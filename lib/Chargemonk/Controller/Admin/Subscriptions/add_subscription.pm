package Chargemonk::Controller::Admin::Subscriptions::add_subscription;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }


use List::MoreUtils qw(zip uniq);

=head1 NAME

Chargemonk::Controller::Admin::Subscriptions::add_subscription - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 features_tab

    Load features tab for selected group

=cut

sub features_tab : Local : Args(1) {
    my ( $self, $c ) = @_;

    my $group         = $c->model('Chargemonk::SubscriptionGroup')->find( {id => $c->req->args->[0]} );
    my @groups        = $c->model('Chargemonk::SubscriptionGroup')->all();
    my @features      = $c->model('Chargemonk::Feature')->all();
    my @subscriptions = $c->model('Chargemonk::Subscription')->search( {subscription_group_id => $group->id} )->all();
    my @link_subscriptions_features = $c->model('Chargemonk::LinkSubscriptionFeature')->all();

    my @reload_features = split ',', $c->req->params->{reload_features};
    my @reload_subscription_features =
        $c->model('Chargemonk::LinkSubscriptionFeature')
        ->search( {subscription_id => $c->req->params->{reload_subscription_features}} )->all()
        if ( $c->req->params->{reload_subscription_features} );
    @reload_subscription_features = map { $_->feature_id } @reload_subscription_features
        if (@reload_subscription_features);
    my @current_features_ids = grep { defined $_ && $_ ne '' } zip( @reload_features, @reload_subscription_features );

    $c->stash(
        {   subscriptions               => \@subscriptions,
            features                    => \@features,
            current_features_ids        => \@current_features_ids,
            link_subscriptions_features => \@link_subscriptions_features,
            current_group               => $c->req->args->[0]
        }
    );
}

=head2 group_tab

    Load group tab for selected group

=cut

sub group_tab : Local : Args(1) {
    my ( $self, $c ) = @_;

    my $group = $c->model('Chargemonk::SubscriptionGroup')->find( {id => $c->req->args->[0]} );

    my @subscriptions = $c->model('Chargemonk::Subscription')->search( {subscription_group_id => $group->id} )->all();
    my @reloaded_subscriptions = split /\|/, $c->req->params->{reload_groups} if ( $c->req->params->{reload_groups} );

    my @ordered_groups = ();

    foreach ( grep { defined } @reloaded_subscriptions // [] ) {
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
        {   reloaded_ordered_groups => [sort { $a->{subscription_order} <=> $b->{subscription_order} } @ordered_groups],
            subscriptions => \@subscriptions,
            current_group => $c->req->args->[0]
        }
    );
}

=head2 upgrade_tab

    Load upgrade tab for selected group

=cut

sub upgrade_tab : Local : Args(1) {
    my ( $self, $c ) = @_;

    my $group = $c->model('Chargemonk::SubscriptionGroup')->find( {id => $c->req->args->[0]} );

    my @subscriptions = $c->model('Chargemonk::Subscription')->search( {subscription_group_id => $group->id} )->all();

    $c->stash(
        {   subscription_upgrade_to_ids => ( $c->req->params->{reload_upgrades} )
            ? [split ",", $c->req->params->{reload_upgrades}]
            : [],
            subscriptions => \@subscriptions,
            current_group => $c->req->args->[0]
        }
    );
}

=head2 downgrade_tab

    Load downgrade tab for selected group

=cut

sub downgrade_tab : Local : Args(1) {
    my ( $self, $c ) = @_;

    my $group = $c->model('Chargemonk::SubscriptionGroup')->find( {id => $c->req->args->[0]} );

    my @subscriptions = $c->model('Chargemonk::Subscription')->search( {subscription_group_id => $group->id} )->all();

    $c->stash(
        {   subscription_downgrade_to_ids => ( $c->req->params->{reload_downgrades} )
            ? [split ",", $c->req->params->{reload_downgrades}]
            : [],
            subscriptions => \@subscriptions,
            current_group => $c->req->args->[0]
        }
    );
}


=head1 AUTHOR

MeSe

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
