package Chargemonk::Helpers::Visitor::Registration;

use Mail::Sendmail;
use String::Random qw(random_regex);

=head1 NAME

Chargemonk::Helpers::Visitor::Registration- Helpers for Chargemonk user registration page

=head1 DESCRIPTION

Chargemonk helpers for user registration page.

=head1 METHODS

=cut

=head2 send_register_user_email

    Helper for sending e-mail for a registering user

=cut

sub send_register_user_email {
    my $args = shift;

    my $token;
    do { $token = random_regex('[a-z0-9]{18}') }
      until (
        not $args->{c}->model('Chargemonk::UserRegistrationToken')
          ->find( { token => $token } ) );

    $args->{c}->model('Chargemonk::UserRegistrationToken')->create(
        {
            user_id         => $args->{user_id},
            link_user_subscription_id => $args->{link_user_subscription_id},
            token           => $token,
            flow_type       => $args->{flow_type},
        }
    );
    
    my $server = $args->{email_page_return};
    my $link_args = ( $args->{trial} ) ? '' : '?token=' . $token . '&lusid=' . $args->{link_user_subscription_id} ;
    sendmail(
        To      => $args->{email},
        From    => 'no-reply@chargemonk.com',
        Subject => 'Activate you email address',
        Message => 'Please activate your email address for your '
          . "Subscription Manager account by following link:\n"
          . ( $server . $link_args )
    );

    return;
}

1;
