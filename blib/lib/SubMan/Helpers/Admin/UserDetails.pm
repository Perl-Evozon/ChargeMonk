package SubMan::Helpers::Admin::UserDetails;

use Mail::Sendmail;
use String::Random qw(random_regex);
use Try::Tiny;

=head1 NAME

SubMan::Helpers::Admin::UserDetails- Helpers for SubMan admin actions on 'User Details' page

=head1 DESCRIPTION

Subman helpers for admin actions available on 'User Details' page.

=head1 METHODS

=cut


=head2 send_set_user_psw_email

    Helper for sending e-mail for a user to set his own password

=cut

sub send_set_user_psw_email {
    my ( $c, $id, $email, $server ) = @_;

    my $user = $c->model('SubMan::User')->find( {id => $id} );

    # get a unique token and save it in db
    my $token;
    try {
        do {
            $token = random_regex('[a-z0-9]{18}');
        } until ( not $c->model('SubMan::UserPswSetToken')->find( {'token' => $token} ) );

        my $user_token = $c->model('SubMan::UserPswSetToken')->search( {uid => $id} )->slice( 0, 0 )->single;
        if ($user_token) {

            # update with new token
            $user_token->update( {token => $token, created => 'now()'} );
        }
        else {
            # create with token
            $c->model('SubMan::UserPswSetToken')->create(
                {   'uid'   => $id,
                    'token' => $token
                }
            );
        }
    }
    catch {

        # create alert
        $c->alert(
            {   'error' =>
                    'Unable to compose the email for the user to set his own password. You can find more details in the error log.'
            },
            "token: $token | email: $email | error : $_"
        );
        return;
    } or return;

    # e-mail user to set his password
    try {
        my %mail = (
            To      => $email,
            From    => 'no-reply@subman.com',
            Subject => 'Set password for your Subscription Manager account',
            Message =>
                "You have the possibility of setting the password for your Subscription Manager account by following link:\n"
                . $server
                . '/set_user_password?token='
                . $token
        );
        sendmail(%mail);    #or die $Mail::Sendmail::error;

        # warn "OK. Log says:\n", $Mail::Sendmail::log;
    }
    catch {

        #create alert
        $c->alert(
            {   'error' =>
                    'Unable to send mail for user to set his password. You can retry later. For more details you can check the logs.'
            },
            "to_email: $email, error: $_"
        );
        return;
    } or return;

    $c->alert( {'success' => "An email was sent to help with setting account's password."},
        "to: $email  |token: $token" );
}

=head2 send_register_user_email

    Helper for sending e-mail for a registering user

=cut

sub send_register_user_email {

}

1;
