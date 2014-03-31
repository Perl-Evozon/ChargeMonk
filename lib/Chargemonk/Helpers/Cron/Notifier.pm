package Chargemonk::Helpers::Cron::Notifier;

use Moose::Role;

=head1 NAME

Chargemonk::Helpers::Cron::Notifier

Module used for notifying the users on different actions

=head1 METHODS


=head2 notify_expiring_subscription

Run the steps required for the cron

=cut

sub notify_expiring_subscription {
    my ( $app, $handle ) = @_;

    my $link_subscription = $handle->{subscription};

    my %mail = (
        To      => $link_subscription->user->email(),
        From    => 'no-reply@chargemonk.com',
        Subject => 'Your subscription is about to expire',
        Message => "Your subscription " . $link_subscription->subscription->name() . " will expire in one day",
    );
    sendmail(%mail);    #or die $Mail::Sendmail::error;
}

=head2 expired_subscription

Run the steps required for the cron

=cut

sub expired_subscription {
    my ( $app, $handle ) = @_;

    my $link_subscription = $handle->{subscription};

    my %mail = (
        To      => $link_subscription->user->email(),
        From    => 'no-reply@chargemonk.com',
        Subject => 'Your subscription has expired',
        Message => "Your subscription " . $link_subscription->subscription->name() . " has expired",
    );
    sendmail(%mail);    #or die $Mail::Sendmail::error;
}

=head2 notify_expiring_trial_period

Run the steps required for the cron

=cut

sub notify_expiring_trial_period {
    my ( $app, $handle ) = @_;

    my $link_subscription = $handle->{subscription};

    my $message =
          "The trial period for the subscription "
        . $link_subscription->subscription->name()
        . " will expire in one day.";

    my %mail = (
        To      => $link_subscription->user->email(),
        From    => 'no-reply@chargemonk.com',
        Subject => 'Your subscription trial is about to expire',
        Message => $message,
    );
    sendmail(%mail);    #or die $Mail::Sendmail::error;
}

=head2 expired_trial

Run the steps required for the cron

=cut

sub expired_trial {
    my ( $app, $handle ) = @_;

    my $link_subscription = $handle->{subscription};

    my $message = "The trial period for the subscription " . $link_subscription->subscription->name() . " has expired.";
    if ( $handle->{process_status} ) {
        $message .= "The regular subscription was created succesfully";
    }
    else {
        $message .= "The regular subscription could not be created, please check your payment details";
    }


    my %mail = (
        To      => $link_subscription->user->email(),
        From    => 'no-reply@chargemonk.com',
        Subject => 'Your subscription trial is about to expire',
        Message => $message,
    );
    sendmail(%mail);    #or die $Mail::Sendmail::error;
}


=head2 notify_auto_renew

Run the steps required for the cron

=cut

sub notify_auto_renew {
    my ( $app, $handle ) = @_;

    my $link_subscription = $handle->{subscription};

    my $message = "Your subscription " . $link_subscription->subscription->name() . " will be auto renewed in one day.";

    my %mail = (
        To      => $link_subscription->user->email(),
        From    => 'no-reply@chargemonk.com',
        Subject => 'Your subscription will be auto renewed',
        Message => $message,
    );
    sendmail(%mail);    #or die $Mail::Sendmail::error;
}


=head2 expired_auto_renew

Run the steps required for the cron

=cut

sub expired_auto_renew {
    my ( $app, $handle ) = @_;

    my $link_subscription = $handle->{subscription};

    my $message = "Your subscription " . $link_subscription->subscription->name();
    if ( $handle->{process_status} ) {
        $message .= " was auto renewed";
    }
    else {
        $message .= " could not be auto renewed";
    }


    my %mail = (
        To      => $link_subscription->user->email(),
        From    => 'no-reply@chargemonk.com',
        Subject => 'Your subscription auto renew',
        Message => $message,
    );
    sendmail(%mail);    #or die $Mail::Sendmail::error;
}


=head2 notify_downgrading

Run the steps required for the cron

=cut

sub notify_downgrading {
    my ( $app, $handle ) = @_;

    my $link_subscription = $handle->{subscription};

    my $message = "Your subscription " . $link_subscription->subscription->name() . " will be downgraded.";

    my %mail = (
        To      => $link_subscription->user->email(),
        From    => 'no-reply@chargemonk.com',
        Subject => 'Your subscription will be downgraded',
        Message => $message,
    );
    sendmail(%mail);    #or die $Mail::Sendmail::error;
}


=head2 expired_downgraded

Run the steps required for the cron

=cut

sub expired_downgraded {
    my ( $app, $handle ) = @_;

    my $link_subscription = $handle->{subscription};
    my $downgrade_to      = $app->model('Chargemonk::Subscription')->find( $handle->{downgrading_to} );

    my $message = "Your subscription " . $link_subscription->subscription->name();
    if ( $handle->{process_status} ) {
        $message .= " was downgraded to " . $downgrade_to->name();
    }
    else {
        $message .= " could not be downgraded to" . $downgrade_to->name();
    }


    my %mail = (
        To      => $link_subscription->user->email(),
        From    => 'no-reply@chargemonk.com',
        Subject => 'Your subscription downgrade',
        Message => $message,
    );
    sendmail(%mail);    #or die $Mail::Sendmail::error;

}


=head2 expired

Nothing to do here, just an intermediate stage

=cut

sub expired {
}

1;
