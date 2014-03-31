package Chargemonk::Controller::Admin::Subscriptions::Tabs;

use Moose;
use namespace::autoclean;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Chargemonk::Controller::Admin::Subscriptions::Tabs - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 features_tab

    Load features tab for selected group

=cut

sub features : Local : Args(1) {
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
    my @current_features_ids = grep { defined $_ && $_ ne '' } ( @reload_features, @reload_subscription_features );

    $c->stash(
        {   subscriptions               => \@subscriptions,
            features                    => \@features,
            current_features_ids        => \@current_features_ids,
            link_subscriptions_features => \@link_subscriptions_features,
            current_group               => $c->req->args->[0]
        }
    );
}


=head2 discount_codes_tab

    Load discount codes tab for selected group

=cut

sub discount_codes : Local : Args(1) {
    my ( $self, $c ) = @_;

    my $subscription_id = ( $c->req->args->[0] || 0 );

    #see if the admin wants to add a new campaign
    $self->create_campaign( $c, $subscription_id ) if ( defined $c->req->param('create_campaign_form') );

    # Get the campaign list based on subscription
    # if the subscription it's not saved yet, get the list of ids recently added
    my $search_params = {id => '-1'};    # shouldn't find enything in this case
    if ($subscription_id) {
        $search_params = {subscription_id => $subscription_id};
    }
    else {
        my $added_campaigns = ( $c->req->param('added_campaigns') || '' );
        my @ids_in = grep { $_ ge 0 } split ',', $added_campaigns;
        $search_params = {id => {'IN', \@ids_in}} if ( scalar(@ids_in) );
    }

    my @campaigns = $c->model('Chargemonk::Campaign')->search($search_params);

    my $campaign_id = $c->stash->{campaign_id}    # just created
        || $c->req->param('campaign_id')          # sent in request
        || ( @campaigns ? $campaigns[0]->id() : 0 );    # first found

    my @codes = $c->model('Chargemonk::Code')->search( {campaign_id => $campaign_id} );

    #see if the admin wants to generate some codes
    if ( defined $c->req->param('generate_codes_form') ) {
        $self->generate_codes( $c, $campaign_id, \@codes );
        @codes = $c->model('Chargemonk::Code')->search( {campaign_id => $campaign_id} );
    }

    $c->stash(
        {   simulate_modal_campaign => ( $c->req->args->[0] eq "simulate_modal_campaign" ) ? 1 : 0,
            subscription_id         => $subscription_id,
            campaign_id             => $campaign_id,
            campaigns               => \@campaigns,
            codes                   => \@codes,
        }
    );
}

=head2 create_campaign

    Creates a new campaign for the given subscription

=cut

sub create_campaign {
    my ( $self, $c, $subscription_id ) = @_;

    my $campaign;
    try {
        $campaign = $c->model('Chargemonk::Campaign')->create(
            {   name            => $c->req->param('name'),
                prefix          => $c->req->param('prefix'),
                nr_of_codes     => $c->req->param('nr_of_codes'),
                start_date      => $c->req->param('start_date'),
                end_date        => $c->req->param('end_date'),
                discount_type   => $c->req->param('discount_type'),
                discount_amount => $c->req->param('discount_amount'),
                valability      => $c->req->param('valability'),
                user_id         => $c->user->id(),
                subscription_id => $subscription_id || undef,
            }
        );

        push( @{$c->session->{campaigns_id}}, $campaign->id );

        $self->generate_codes( $c, $campaign->id(), [] );
        
        $c->alert( {success => 'The campaign was created successfully'} );

        $c->stash( {campaign_id => $campaign->id,} );
    }
    catch {
        $c->alert( {error => 'There was an error while creating the new campaign. Please check the log.'}, $_ );
        return;
    } or return;
}


=head2 generate_codes

    Generate codes for the given campaign

=cut

sub generate_codes {
    my ( $self, $c, $campaign_id, $existing_codes ) = @_;

    my $campaign = $c->model('Chargemonk::Campaign')->find($campaign_id);

#my $codes_remaining = $campaign->nr_of_codes() - scalar(@$existing_codes);
#if ( $codes_remaining - $c->req->param('nr_of_codes')  < 0 ) {
#    push( @{$alerts}, {error => "$codes_remaining code".($codes_remaining != 1 ? 's' : '')." left on this campaign."} );
#    return 0;
#}

    try {
        for ( my $i = 1; $i <= $c->req->param('nr_of_codes'); $i++ ) {
            my @chars = ( 0 .. 9 );
            my $code = $c->req->param('prefix') . join( "", @chars[map { rand @chars } ( 1 .. 8 )] );
            $c->model('Chargemonk::Code')->create(
                {   campaign_id => $campaign->id,
                    code        => $code,
                }
            );
        }
        $c->alert( {success => 'The codes were generated successfully'} );
    }
    catch {
        $c->alert( {error => 'There was an error while generating the codes.'}, $_ );
        return;
    } or return;
}


__PACKAGE__->meta->make_immutable;

1;
