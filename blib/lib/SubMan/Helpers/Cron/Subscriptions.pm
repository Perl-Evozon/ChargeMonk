package SubMan::Helpers::Cron::Subscriptions;

use Data::Dumper;
use DateTime::Format::Pg;
use Module::Load;
use Moose;
use namespace::autoclean;
use Storable qw( dclone );
use Try::Tiny;

use SubMan;
use SubMan::Helpers::Common::DateTime qw( timestamp );
use SubMan::Helpers::Gateways::Details qw(get_active_gateway get_gateway_credentials);

use SubMan::Helpers::Gateways::Authorize;
use SubMan::Helpers::Gateways::Braintree;
use SubMan::Helpers::Gateways::Stripe;

has '_app' => (
    is      => 'rw',
    isa     => 'SubMan',
    default => sub { SubMan->new() },
);
has 'simulate' => ( is => 'rw', isa => 'Str' );
has 'datetime' => ( is => 'rw', isa => 'DateTime', default => sub { DateTime->now() } );
has 'alert_before' => ( is => 'rw', isa => 'Int', default => 1 );    # days
has 'handled_subscriptions' => ( is => 'rw', isa => 'ArrayRef' );    # linked subscriptions

# Notification functions implemented here
with 'SubMan::Helpers::Cron::Notifier';

=head1 NAME

SubMan::Helpers::Cron::Subscriptions

Module used for planned operations on subscriptions,
like downgrade, expire, renew, cancel

The cron will run in three steps mainly
 - build a list of subscriptions that need to be handled
 - do the required actions
 - notify users on the actions took
 
Some notes on the algorythm
 - it will only take care of the linked subscriptions that
    - are about to expire ( curr_date  + alert_before_delta > end_date)
    - are expired(curr_date > end_date)

The cron will run at every few hours and will only pick up the subscriptions that are not already
processed (marked with processed time, and process stage)

=head1 METHODS

=head2 run

Run the steps required for the cron

=cut


sub run {
    my $self = shift;

    $self->_build_handled_subscriptions();

    $self->_classify_subscriptions();

    $self->_do_planned_actions();

    $self->_send_alerts() unless ( $self->simulate );

    return $self->handled_subscriptions;
}


=head2 _build_handled_subscriptions

Get the list of link subscriptions that need to be taken care of

=cut

sub _build_handled_subscriptions {
    my $self = shift;

    my $dt   = dclone $self->datetime;                                       # current date
    my @subs = $self->_app->model('SubMan::LinkUserSubscription')->search(
        {
            # only pick up the ones that are about to expire and the ones expired
            active_to_date => {'<=', timestamp( $dt->add( days => $self->alert_before() ) )},
        }
    );
    $self->handled_subscriptions( [map { {subscription => $_} } @subs] );

    return $self->handled_subscriptions;
}


=head2 run

Do the required actions on the subscriptions found

=cut

sub _do_planned_actions {
    my $self = shift;

    foreach my $element ( @{$self->handled_subscriptions()} ) {

        my $process_status = 0;

        # the subscription is expired, curr_date > end_date
        if ( $element->{process_message} eq 'expired' ) {
            my $link_subscription = $element->{subscription};

            # do the processing based on the flags set on the previous stage
            my $prev_stage = $link_subscription->process_message();
            if ( $prev_stage eq 'notify_expiring_subscription' ) {

                # subscription is closing
                # nothing else to do here, just make the link subscription inactive, check below
                $element->{process_message} = 'expired_subscription';
            }
            elsif ( $prev_stage eq 'notify_expiring_trial_period' ) {

                # trial period is finished, we need to switch to the regular
                $element->{process_message} = 'expired_trial';

                # add regular subscription
                $self->_add_link_subscription($element);

            }
            elsif ( $prev_stage eq 'notify_auto_renew' ) {

                # auto renew subscription
                $element->{process_message} = 'expired_auto_renew';

                # this will basically try to add another subscription like the one existing
                $self->_add_link_subscription($element);
            }
            elsif ( $prev_stage eq 'notify_downgrading' ) {
                $element->{process_message} = 'expired_downgraded';
                my $downgrade_id = $1;

                # TODO: what about the payment for the downgraded subscription
                # the downgrade link subscription should exist already, just need to be made active
                my @downgrade = $self->_app->model('SubMan::LinkUserSubscription')->search(
                    {
                        # only pick up the ones that are about to expire and the ones expired
                        user_id          => $link_subscription->user->id(),
                        active_from_date => {'>=', timestamp( $self->datetime() )},
                        active           => 0,
                        cancelled        => 0,
                    }
                );
                if ( scalar(@downgrade) ) {
                    $downgrade[0]->update( {active => 1} );
                    $element->{process_status} = 1;
                    $element->{downgrading_to}  = $downgrade[0]->subscription->id();
                }
                else {
                    $element->{process_status} = 0;
                    push @{$element->{alerts}}, "Couldn't find the downgrading subscription";
                }

            }
        }
        elsif ( $element->{process_message} =~ /(notify_(.*))/ ) {

            #send notifications based on the message type
            $process_status = 1;
        }

        # mark link subscription: process date, message, process result
        my $update_data = {
            process_status  => $process_status,
            process_message => $element->{process_message},
            process_date    => timestamp( $self->datetime ),
        };
        $update_data->{active} = 0 if ( $element->{process_message} =~ /expired/ );

        # TODO: unless simulate?
        $element->{subscription}->update($update_data);
    }

}


=head2 _clasify_subscriptions

Notify users about specific actions

=cut

sub _classify_subscriptions {
    my $self = shift;

    foreach my $element ( @{$self->handled_subscriptions()} ) {
        my $link_subscription = $element->{subscription};
        my $subscription      = $link_subscription->subscription();

        # about to expire
        if ( timestamp( $self->datetime ) lt timestamp( $link_subscription->active_to_date ) )
        {    #one day before the end of period (trial or regular)

            # check if we are on the trial period:
            #  add trial days to the link subscription start date
            # then compare with the current date
            my $dt_start = dclone $link_subscription->active_from_date();

            # has trial and we are within the trial period
            if ($subscription->has_trial()
                && ( $subscription->trial_period
                    && timestamp( $self->datetime )
                    lt timestamp( $dt_start->add( days => $subscription->trial_period ) ) )
                )
            {
                # trial is ending, regular subs is starting
                $element->{process_message} = 'notify_expiring_trial_period';

                # TODO: if trial period < regular period => create regular subscription
            }
            else {
                # full period is ending

                # looking for downgrade subscription
                # subscription with active = 0, cancelled = 0 and start_date the next day
                my @downgrade = $self->_app->model('SubMan::LinkUserSubscription')->search(
                    {
                        # only pick up the ones that are about to expire and the ones expired
                        user_id          => $link_subscription->user->id(),
                        active_from_date => {'>=', timestamp( $self->datetime() )},
                        active           => 0,
                        cancelled        => 0,
                    }
                );

                if ( scalar(@downgrade) ) {
                    $element->{process_message} = 'notify_downgrading';
                    $element->{downgrading_to}  = $downgrade[0]->subscription->id();
                }
                elsif ( $subscription->has_auto_renew() ) {

                    # subscription will be auto renewed
                    $element->{process_message} = 'notify_auto_renew';
                }
                else {
                    # subscription will be closed
                    $element->{process_message} = 'notify_expiring_subscription';
                }

            }

        }
        else {    # expired
            $element->{process_message} = 'expired';
        }
    }
}


=head2 _send_alerts

Notify users about specific actions

=cut

sub _send_alerts {
    my $self = shift;

    return if ( $self->simulate );
    
    foreach my $handle ( @{$self->handled_subscriptions()} ) {
        
        # the notify functions are defined in the Notifier
        my $res = eval("$handle->{process_message}(\$self->_app, \$handle)");
    }
}


=head2 _add_link_subscription

Add regular subscription

=cut

sub _add_link_subscription {
    my ( $self, $handle ) = @_;

    my $link_subscription = $handle->{subscription};
    my $dt                = dclone $self->datetime;
    my $new_link_user_subscription;
    try {

        $new_link_user_subscription = $self->_app->model('SubMan::LinkUserSubscription')->create(
            {   user_id            => $link_subscription->user_id(),
                subscription_id    => $link_subscription->subscription_id(),
                nr_of_period_users => 1,
                active_from_date   => timestamp($dt),
                active_to_date     => timestamp( $dt->add( days => $link_subscription->subscription->period() ) ),
                active             => 0,
            }
        );
    }
    catch {
        push(
            @{$handle->{alerts}},
            {'error' => 'Unable to create subscription. Please check the error log for more details.'}
        );
        $self->_app->logger->error(
            sprintf(
                'Unable to create subscription (%s) for user (%s): %s',
                $link_subscription->subscription_id(),
                $link_subscription->user_id(), $_
            )
        );
        $handle->{process_status} = 0;

        return;
    } or return;

    my $gateway = get_active_gateway();
    my $gateway_credentials = get_gateway_credentials( $self->_app, $gateway );

    $gateway = 'SubMan::Helpers::Gateways::' . ucfirst($gateway);
    my $active_gateway = $gateway->new(
        args => {
            c                   => $self->_app,
            gateway_credentials => $gateway_credentials,
            link_user_subscription_id => $new_link_user_subscription->id,
            alerts                    => $handle->{alerts},
            amount                    => $new_link_user_subscription->amount_with_discount() || $new_link_user_subscription->subscription->price(),
        }
    );
    my $res = $active_gateway->pay();

    if ( $res ) {
        $new_link_user_subscription->update( {active => 1} );
        push( @{$handle->{alerts}}, {'success' => 'Payment completed successfully for link subscription:'.$new_link_user_subscription->id()} );
        $handle->{process_status} = 1;
    }
    else {
        $handle->{process_status} = 0;
        $new_link_user_subscription->delete();
    }

}


__PACKAGE__->meta->make_immutable;

1;

