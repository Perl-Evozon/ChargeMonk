package Chargemonk::Controller::Admin::Profile;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Chargemonk::Controller::Authenticated'; }

=head1 NAME

Chargemonk::Controller::Admin::Profile - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 profile

Controller for admin 'Profile' page

=cut

sub profile :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash({user => $c->user});
}

=head2 edit

  Controller for admin 'Edit Profile' page.

=cut

sub edit :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->go( "/admin/users/edit_user/".$c->user->id );
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

mar_k

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
