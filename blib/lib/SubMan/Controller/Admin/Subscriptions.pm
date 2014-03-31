package SubMan::Controller::Admin::Subscriptions;

use DateTime;
use Moose;
use namespace::autoclean;
use Try::Tiny;

use SubMan::Helpers::Common::DateTime qw(convert_to_days);

BEGIN { extends 'SubMan::Controller::Authenticated'; }

=head1 NAME

SubMan::Controller::Admin::Subscription - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

my $subsciption_validation_rules = {
    name                    => ['NotEmpty'                      => 'Name can not be empty'],
    subscription_type       => ['NotEmpty'                      => 'Please select a subscription type'],
    access_type             => ['NotEmpty'                      => 'Please select an access type'],
    period                  => ['Subscription::CheckAccessType' => 'Period can not be empty'],
    period_unit             => ['Subscription::CheckAccessType' => 'Please select a period unit'],
    price                   => ['Subscription::CheckAccessType' => 'Price can not be empty'],
    currency                => ['Subscription::CheckAccessType' => 'Please select currency'],
    call_to_action          => ['Subscription::CheckAccessType' => 'Call To Action can not be empty'],
    min_active_period_users => ['Subscription::CheckAccessType' => 'Min. number of concurrent users can not be empty'],
    max_active_period_users => ['Subscription::CheckAccessType' => 'Max. number of concurrent users can not be empty'],
    resource_type           => ['Subscription::CheckAccessType' => 'Resource Type can not be empty'],
    min_resource_quantity => ['Subscription::CheckAccessType' => 'Min. number of resource quantities can not be empty'],
    max_resource_quantity => ['Subscription::CheckAccessType' => 'Max. number of resource quantities can not be empty'],
    min_active_ips        => ['Subscription::CheckAccessType' => 'Min. number of active ips can not be empty'],
    max_active_ips        => ['Subscription::CheckAccessType' => 'Max. number of active ips can not be empty'],
    api_calls_volume      => ['Subscription::CheckAccessType' => 'Volume can not be empty'],
    trial_period          => ['Subscription::CheckTrial'      => 'Trial period can not be empty'],
    trial_period_unit     => ['Subscription::CheckTrial'      => 'Please select a trial period unit']
};

=head2 auto

Forward the group actions to the group controller from here
The reason we do it from here instead of calling the group paths directly is
the modal and alerts display and also the url and redirects

=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    my $group_dispatcher = {
        create_this_group => '/admin/subscriptiongroups/add_group',
        delete_this_group => '/admin/subscriptiongroups/delete_group',
        edit_this_group   => '/admin/subscriptiongroups/edit_group',
    };
    foreach ( keys %$group_dispatcher ) {
        $c->forward( $group_dispatcher->{$_} ) if ( defined $c->req->param($_) && $c->req->method eq 'POST' );
    }

    return 1;
}


=head2 subscriptions

Controller for admin 'Subscriptions' page

=cut

sub list_subscriptions : Path : Args(0) {
}


=head2 add_subscription

    Add subscription handler -render remplate

=cut

sub add_subscription : Local : Args(0) {
    my ( $self, $c ) = @_;

    my $reload_data = $self->_reinitialize_subscription_data($c);

    $c->stash($reload_data);

}

=head2 save

    Save new subscription handler

=cut

__PACKAGE__->validation_rules( save => $subsciption_validation_rules );

sub save : Local : Args(0) : OnError(add_subscription) {
    my ( $self, $c ) = @_;

    # add subscription
    my $subscription;
    try {
        $subscription = $c->model('SubMan::Subscription')->create( $self->_initial_hash($c) );

        #link the created campaings to the new campaign
        $c->model('SubMan::LinkCampaignsSubscription')->create(
            {   subscription_id => $subscription->id,
                campaign_id     => $_
            }
        ) foreach @{$c->session->{campaigns_id}};

        #clear campaing ids stored
        delete $c->session->{campaigns_id};

        #update with the request data
        $self->_update_subscription_data( $c, $subscription );

        my $success = "The subscription '" . $subscription->name() . "' was created.";
        $c->logger->info($success);
        $c->alert( {'success' => $success} );
    }
    catch {
        my $error = "Unable to create subscription";
        $c->logger->error( $error . " : $_" );
        $c->alert( {'error' => "$error. Please check the error log for more details"} );
    };

    $c->go('add_subscription');
    $c->detach();
}


=head2 edit_subscription

    Edit subscription handler

=cut

sub edit_subscription : Local : Args(1) {
    my ( $self, $c ) = @_;

    my $subscription_id = $c->req->args->[0];
    my $reload_data     = $self->_reinitialize_subscription_data($c);
    my $subscription    = $c->model('SubMan::Subscription')->find($subscription_id);
    $c->forward( 'subscription_not_found', [$subscription_id] ) if ( !$subscription );

    $c->stash($reload_data);
    $c->stash->{subscription} = $subscription;
}

__PACKAGE__->validation_rules( update => $subsciption_validation_rules );

sub update : Local : Args(1) : OnError(edit_subscription) {
    my ( $self, $c ) = @_;

    my $subscription_id = $c->req->args->[0];
    my $subscription    = $c->model('SubMan::Subscription')->find($subscription_id);
    $c->forward( 'subscription_not_found', [$subscription_id] ) if ( !$subscription );


    # do the necessary changes if update form was submitted
    if ( defined $c->req->param('edit_this_subscription') ) {
        try {
            $subscription->update( $self->_initial_hash($c) );
            $self->_update_subscription_data( $c, $subscription );

            $c->alert( {'success' => "The subscription '" . $subscription->name() . "' was updated."} );
        }
        catch {
            $c->alert(
                {         'error' => "The subscription '"
                        . $subscription->name()
                        . "' could not be updated. Please check the error log for more details"
                },
                $_
            );
        };
    }    # END edit_this_subscription

    $c->stash( {subscription => $subscription} );

    $c->go( 'edit_subscription', [$subscription_id] );
    $c->detach();
}


=head2 subscription_details

Controller for admin 'Subscription Details' page

=cut

sub subscription_details : Local : Args(1) {
    my ( $self, $c ) = @_;

    my $subscription_id = $c->req->args->[0];
    my $subscription    = $c->model('SubMan::Subscription')->find($subscription_id);
    $c->forward( 'subscription_not_found', [$subscription_id] ) if ( !$subscription );

    my ( $group, @upgrades, @downgrades, @subscriptions_from_group, @link_subscriptions_features );

    try {
        $group      = $c->model('SubMan::SubscriptionGroup')->find( $subscription->subscription_group_id() );
        @upgrades   = $c->model('SubMan::SubscriptionUpgradeTo')->search( {subscription_id => $subscription->id()} );
        @downgrades = $c->model('SubMan::SubscriptionDowngradeTo')->search( {subscription_id => $subscription->id()} );
        @subscriptions_from_group = $c->model('SubMan::Subscription')
            ->search( {subscription_group_id => $subscription->subscription_group_id()} );
        @link_subscriptions_features =
            $c->model('SubMan::LinkSubscriptionFeature')->search( {subscription_id => $subscription->id()} );
    }
    catch {
        my $error = "Could not retrieve details for subscription id '$subscription_id'";
        $c->logger->error( $error . " : $_" );
        $c->alert( {'error' => "$error. Please check the error log for more details"} );
    };

    $c->stash(
        {   subscription                => $subscription,
            upgrades                    => \@upgrades,
            downgrades                  => \@downgrades,
            group                       => $group,
            subscriptions_from_group    => \@subscriptions_from_group,
            link_subscriptions_features => \@link_subscriptions_features,
        }
    );
}


=head2 go_home

Go to subscriptions home in case something's wrong

=cut

sub go_home : Private {
    my ( $self, $c ) = @_;

    $c->go('/admin/subscriptions/list_subscriptions');
}

=head2 go_home

Go to subscriptions home in case something's wrong

=cut

sub subscription_not_found : Private {
    my ( $self, $c, $subscription_id ) = @_;

    my $error = "Could not retrieve subscription '$subscription_id'";
    push @{$c->stash->{alerts}}, {'error' => "$error. Please check the error log for more details"};
    $c->forward('go_home');
}


=head2 end

Put the general stuff in the stash

=cut

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;

    my @groups                      = $c->model('SubMan::SubscriptionGroup')->all();
    my @features                    = $c->model('SubMan::Feature')->all();
    my @subscriptions               = $c->stash->{subscriptions} || $c->model('SubMan::Subscription')->all();
    my @link_subscriptions_features = $c->model('SubMan::LinkSubscriptionFeature')->all();

    $c->stash(
        {   subscriptions => $c->stash->{subscriptions}
                || \@subscriptions,
            groups                      => \@groups,
            features                    => \@features,
            link_subscriptions_features => $c->stash->{link_subscriptions_features}
                || \@link_subscriptions_features,    # could be in stash already
            simulate_modal          => $c->req->param('simulate_modal')          || 0,
            simulate_modal_campaign => $c->req->param('simulate_modal_campaign') || 0,
        }
    );
}


=head2 _initial_hash

Return a hash with the initial flags for the subscription,
some of them from request, others initialized with undef

=cut

sub _initial_hash : Private {
    my ( $self, $c ) = @_;

    # Initialize the subscription params
    my $subscription_data = {
        has_trial         => 0,
        created_by        => ( $c->user ) ? $c->user->firstname() . ' ' . $c->user->lastname() : '',
        position_in_group => 0,
    };

    # flags from request
    map { $subscription_data->{$_} = ( defined $c->req->param($_) ? $c->req->param($_) : undef ) }
        qw( name subscription_type subscription_group_id is_visible require_company_data has_auto_renew access_type call_to_action has_trial);

    # initialized with undef:
    map { $subscription_data->{$_} = undef }
        qw( period period_count period_unit price currency trial_period trial_period_count trial_period_unit trial_price trial_currency
        require_credit_card min_active_period_users max_active_period_users
        resource_type min_resource_quantity max_resource_quantity min_active_ips max_active_ips
        api_calls_volume);

    return $subscription_data;
}


=head2 _set_request_data

Update the subscription with the data sent on add/update

=cut

sub _update_subscription_data : Private {
    my ( $self, $c, $subscription ) = @_;

    # set specific flags for specific type or access_type  resource type flags
    my $types = [
        {   condition => ( $c->req->param('subscription_type') eq 'regular' ) || 0,
            flags     => [qw(period period_unit price currency)],
            extra     => sub {
                my $s = shift;
                $s->{period_count} = convert_to_days( $c->req->param('period'), $c->req->param('period_unit') );
                return $s;
            },
        },
        {   condition => ( $c->req->param('subscription_type') eq 'promo' or $c->req->param('has_trial') ) || 0,
            flags => [
                qw(period price period_unit trial_period trial_period_unit trial_price trial_currency require_credit_card)
            ],
            extra => sub {
                my $s = shift;
                $s->{has_trial} = 1;
                $s->{trial_period_count} =
                    convert_to_days( $c->req->param('trial_period'), $c->req->param('trial_period_unit') );
                $s->{period_count} = convert_to_days( $c->req->param('period'), $c->req->param('period_unit') );
                return $s;
            },
        },
        {   condition => ( $c->req->param('access_type') eq 'period_users' ) || 0,
            flags => [qw(min_active_period_users max_active_period_users)],
        },
        {   condition => ( $c->req->param('access_type') eq 'resources' ) || 0,
            flags => [qw(resource_type min_resource_quantity max_resource_quantity)],
        },
        {   condition => ( $c->req->param('access_type') eq 'IP_range' ) || 0,
            flags => [qw(min_active_ips max_active_ips)],
        },
        {   condition => ( $c->req->param('access_type') eq 'API_calls' ) || 0,
            flags => [qw(api_calls_volume)],
        },
    ];

    my $update = {};
    foreach my $type (@$types) {
        next unless ( $type->{condition} );
        map { $update->{$_} = ( defined $c->req->param($_) ? $c->req->param($_) : undef ) } @{$type->{flags}};
        $type->{extra}->($update) if defined $type->{extra};
    }
    $subscription->update($update);


    # ==Features==
    # delete existing features
    foreach ( $c->model('SubMan::LinkSubscriptionFeature')->search( {subscription_id => $subscription->id} )->all ) {
        $_->delete;
    }

    # add features
    my @features = $c->req->param('selected_features');
    if ( $c->req->param('import_features_from_subscr') ) {

        # import the features from this subscription id
        my @imported_features = $c->model('SubMan::LinkSubscriptionFeature')
            ->search( {subscription_id => $c->req->param('import_features_from_subscr')} )->all();
        unshift @features, map { $_->feature_id } @imported_features;
    }
    foreach my $id (@features) {
        $c->model('SubMan::LinkSubscriptionFeature')->update_or_create(
            {   'subscription_id' => $subscription->id,
                'feature_id'      => $id
            }
        );
    }

    # ==Upgrades/Downgrades==
    # add updates_to for subscription
    foreach ( $c->model('SubMan::SubscriptionUpgradeTo')->search( {subscription_id => $subscription->id} )->all ) {
        $_->delete;
    }
    my @upgrades = $c->req->param('selected_upgrades');
    foreach my $id (@upgrades) {
        $c->model('SubMan::SubscriptionUpgradeTo')->update_or_create(
            {   'subscription_id'         => $subscription->id,
                'subscription_upgrade_id' => $id
            }
        );
    }

    # add downgrades_to for subscription
    foreach ( $c->model('SubMan::SubscriptionDowngradeTo')->search( {subscription_id => $subscription->id} )->all ) {
        $_->delete;
    }
    my @downgrades = $c->req->param('selected_downgrades');
    foreach my $id (@downgrades) {
        $c->model('SubMan::SubscriptionDowngradeTo')->update_or_create(
            {   'subscription_id'           => $subscription->id,
                'subscription_downgrade_id' => $id
            }
        );
    }

    my @subscriptions_from_group =
        $c->model('SubMan::Subscription')->search( {subscription_group_id => $subscription->subscription_group_id()} );
    $c->stash->{subscriptions} = \@subscriptions_from_group;

    # ==Subscriptions order==
    my @subscriptions_order = $c->req->param('selected_group_order');
    for ( 0 .. $#subscriptions_order ) {
        my $sub_name = $subscriptions_order[$_];
        my $sub =
            [grep { $_->name eq $sub_name || $_->name eq $subscription->name } @subscriptions_from_group]->[0];
        $sub->update( {position_in_group => $_ + 1} );
    }

    # Added campaigns on an unsaved subscription
    if ( my $campaigns = $c->req->param('added_campaigns') ) {
        my @camp_ids = split ',', $campaigns;
        foreach (@camp_ids) {
            next if !$_;
            my $camp = $c->model('SubMan::Campaign')->find($_);
            $camp->update( {subscription_id => $subscription->id()} ) if ($camp);
        }
    }


}

sub _reinitialize_subscription_data : Private {
    my ( $self, $c ) = @_;

    my $selected_features =
        ( $c->req->params->{selected_features} && ref $c->req->params->{selected_features} eq 'ARRAY' )
        ? join ",", @{$c->req->params->{selected_features}}
        : $c->req->params->{selected_features};
    my $group_index = 0;
    my $selected_groups =
        ( ref $c->req->params->{selected_group_order} eq "ARRAY" )
        ? join "\|", map { $group_index++ . "__$_" } @{$c->req->params->{selected_group_order}}
        : $c->req->params->{selected_group_order};
    my $selected_upgrades =
        ( $c->req->params->{selected_upgrades} && ref $c->req->params->{selected_upgrades} eq 'ARRAY' )
        ? join ",", @{$c->req->params->{selected_upgrades}}
        : $c->req->params->{selected_upgrades};
    my $selected_downgrades =
        ( $c->req->params->{selected_downgrades} && ref $c->req->params->{selected_downgrades} eq 'ARRAY' )
        ? join ",", @{$c->req->params->{selected_downgrades}}
        : $c->req->params->{selected_downgrades};

    my $reload_data = {
        reload_features              => $selected_features,
        reload_subscription_features => $c->req->params->{import_features_from_subscr},
        reload_groups                => $selected_groups,
        reload_upgrades              => $selected_upgrades,
        reload_downgrades            => $selected_downgrades,
        added_campaigns              => ( $c->req->param('added_campaigns') || '' ),
    };

    return $reload_data;
}

__PACKAGE__->meta->make_immutable;

1;
