package Chargemonk::Controller::Admin::Payment_gateways;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Chargemonk::Controller::Authenticated'; }

=head1 NAME

Chargemonk::Controller::Admin::Payment_gateways - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 payment_gateways

Controller for admin 'Payment gateways' page

=cut

sub payment_gateways :Path :Args(0) {
    my ( $self, $c ) = @_;

}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}


=head1 AUTHOR

MeSe

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
