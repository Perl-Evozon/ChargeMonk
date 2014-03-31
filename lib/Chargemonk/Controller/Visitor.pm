package Chargemonk::Controller::Visitor;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Chargemonk::Controller::Authenticated'; }

=head1 NAME

Chargemonk::Controller::Visitor- Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 login 

    Controller that handles user login

=cut

sub login : Global : Args(0) {
    my ( $self, $c ) = @_;

    if ( $c->authenticate( {email => $c->req->param('email'), password => $c->req->param('password')} ) ) {

        # TODO: move expire constant to config
        $c->change_session_expires(86400) if $c->req->param('remember');

        $c->logger->info('Logged in');

        $c->res->redirect('/');
    }
    else {
        $c->res->status(401);
        $c->stash( error => 1 );
        $c->logger->warn('Login failed. Wrong username/password.');
    }
}

=head2 logout
    logout user and delete session for the user
=cut

sub logout : Global : Args(0) : Public {
    my ( $self, $c ) = @_;

    unless ( $c->user ) {
        $c->res->redirect('/index.html');
        $c->detach();
    }
    $c->logger->info('Logged out. Session terminated');

    $c->logout();

    $c->res->redirect('/index.html');
}

=head2 forgot_password 

    Controller that helps you set a new password

=cut

sub forgot_password : Global : Args(0) : Public {
    my ( $self, $c ) = @_;

    return unless $c->req->params;

    my $user = $c->model('Chargemonk::User')->find( {'email' => $c->req->param('email')} );

    if ( !$user ) {
        return $c->alert( {error => 'Email not found'});
    }

    Chargemonk::Helpers::Admin::UserDetails::send_set_user_psw_email( $c, $user->id, $user->email,
        'http://' . $c->req->env->{'HTTP_HOST'} );
}


=head2 set_user_password 

    Controller that handles password setting for new users

=cut

sub set_user_password : Global : Args(0) : Public {
    my ( $self, $c ) = @_;
    $c->stash( {has_subheader => 1} );
    my $token = $c->req->param('token');
    return unless $token;

    my $user_token = $c->model('Chargemonk::UserPswSetToken')->search( {'token' => $token} )->slice( 0, 0 )->single;
    my $user = $user_token->uid if $user_token;

    return $c->stash( {wrong_token_msg => 'Token is no longer valid!'} )
        unless ($user);
    return $c->stash( {user => $user, token => $token} )
        unless ( defined $c->req->param('get_password') or defined $c->req->param('re_password') );
    return $c->stash( {wrong_data_msg => "Password field should not be empty!", user => $user, token => $token} )
        unless $c->req->param('get_password');
    return $c->stash(
        {wrong_data_msg => "Re-type password field should not be empty!", user => $user, token => $token} )
        unless $c->req->param('re_password');

    if ( $c->req->param('get_password') eq $c->req->param('re_password') ) {
        $user->update( {'password' => $c->req->param('get_password')} );
        $c->stash( {password_set_ok => 'Your password was set successfully!', user => $user} );
        $c->logger->info('Password has been set.');

        # remove the token for user
        $user_token->delete();
    }
    else {
        $c->stash( {wrong_data_msg => 'Passwords do not match!', user => $user, token => $token} );
        $c->logger->warn('Failed setting password.');
    }

    return;
}

=head1 AUTHOR

natasha

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
