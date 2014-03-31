package SubMan::Controller::API::Base;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config( default => 'application/json' );

=head1 NAME

SubMan::API::Base - Base class for the API 

=head1 DESCRIPTION

SubMan API
    returns JSON by default
=cut


=head2 begin

Check that the user is logged in - Cut the request flow otherwise.

=cut

sub begin : Private {
    my ( $self, $c ) = @_;

    my $attributes = $c->action()->attributes();

    my $valid_token = 0;

    return 1
        if ( exists $attributes->{Public}
        || ( $c->session && $c->user )
        || ( $c->req->params->{email} && $c->req->params->{password} && $c->action =~ /login/i ) );

    $c->response->redirect("/error?code=not_authorized");
}


=head1 AUTHOR

Ovidiu

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
