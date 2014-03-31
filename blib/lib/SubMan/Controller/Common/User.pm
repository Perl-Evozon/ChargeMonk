package SubMan::Controller::Common::User;

use MIME::Base64;
use Moose;
use namespace::autoclean;
use Try::Tiny;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

SubMan::Controller::Common::User - Catalyst Controller

=head1 DESCRIPTION

Some common functions for user

=head1 METHODS

=cut

=head2 auto

sets the wrapper for the template files so we can call this controller
either as an admin or as a simple user.

=cut

sub auto : Private {
    my ( $self, $c ) = @_;
	
    unless ( $c->user ) {
        $c->res->redirect('/index.html');
        $c->detach();
    }
	
    return 1;
}


=head2 _save_photo

Save profile photo

=cut

sub _save_photo : Private {
    my ( $self, $c, $user ) = @_;

    my $photo_path = $c->path_to( 'root', 'static', 'profile_picture' );
    my $photo_name;
    try {
        my $image_stream = $c->req->param('photo_input');
        if ( $image_stream =~ /(.*?)\s*base64,\s*(.*)$/m ) {
            $image_stream = $2;
        }

        my $decoded = MIME::Base64::decode_base64($image_stream);
        $photo_name = 'user_' . $user->id . '.png';
        open my $fh, '>', $photo_path . '/' . $photo_name or die $!;
        binmode $fh;
        print $fh $decoded;
        close $fh;

        $user->update( {'profile_picture' => '/static/profile_picture/' . $photo_name} ) if ($photo_name);
    }
    catch {
        my $err = 'Unable to save the photo for the user. Please check the error log for more details.';
        $c->alert( {'error' => $err} );
        $c->logger->error( $err . " : user " . $user->id() . " | err : $_" );
    };
}


=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') { }

=head1 AUTHOR

Ovidiu

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
