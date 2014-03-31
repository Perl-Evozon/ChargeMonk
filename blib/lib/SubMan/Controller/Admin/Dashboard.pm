package SubMan::Controller::Admin::Dashboard;
use Moose;
use namespace::autoclean;

BEGIN { extends 'SubMan::Controller::Authenticated'; }

=head1 NAME

SubMan::Controller::Admin::Dashboard - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 dashboard

Controller for admin dashboard page.

=cut

sub dashboard :Path :Args(0) {
    my ( $self, $c ) = @_;

}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Florin Mesaros

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


__PACKAGE__->meta->make_immutable;

1;
