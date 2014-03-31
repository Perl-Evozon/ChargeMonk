package SubMan::Controller::Admin::Registration;

use Moose;
use namespace::autoclean;
use Try::Tiny;

BEGIN { extends 'SubMan::Controller::Authenticated'; }

=head1 NAME

SubMan::Controller::Admin::Registration - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 registration

Controller for admin 'Registration' page

=cut

sub registration : Path : Args(0) {
    my ( $self, $c ) = @_;

    my $registration = $c->model('SubMan::Registration')->find( {id => 1} );

    $c->stash( {registration => $registration} );

    return unless $c->req->param;

    try {
        $c->model('SubMan::Registration')->update_or_create(
            {   id              => 1,
                sex             => $c->req->param('sex') ? 1 : 0,
                first_name      => $c->req->param('first_name') ? 1 : 0,
                last_name       => $c->req->param('last_name') ? 1 : 0,
                date_of_birth   => $c->req->param('date_of_birth') ? 1 : 0,
                address         => $c->req->param('address') ? 1 : 0,
                address_2       => $c->req->param('address_2') ? 1 : 0,
                country         => $c->req->param('country') ? 1 : 0,
                state           => $c->req->param('state') ? 1 : 0,
                zip_code        => $c->req->param('zip_code') ? 1 : 0,
                phone_number    => $c->req->param('phone_number') ? 1 : 0,
                company_name    => $c->req->param('company_name') ? 1 : 0,
                company_address => $c->req->param('company_address') ? 1 : 0,
                company_country => $c->req->param('company_country') ? 1 : 0,
                company_state   => $c->req->param('company_state') ? 1 : 0,
                company_zip_code => $c->req->param('company_zip_code') ? 1
                : 0,
                company_phone_number => $c->req->param('company_phone_number') ? 1
                : 0,
            }
        );
        $c->alert( {success => 'The registration settings were updated.'} );
    }
    catch {
        $c->logger->error("Unable to update registration: $_");
        $c->alert(
            {   error => 'The registration settings could not be updated. '
                    . 'Please check the error log for more details.'
            }
        );
        return;
    } or return;

    return $c->response->redirect('/admin/registration');
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') { }

=head1 AUTHOR

MeSe

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
