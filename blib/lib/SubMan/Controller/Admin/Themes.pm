package SubMan::Controller::Admin::Themes;

use Moose;
use namespace::autoclean;
use MIME::Base64;
use Try::Tiny;

use File::Path 'remove_tree';

BEGIN { extends 'SubMan::Controller::Authenticated'; }

=head1 NAME

SubMan::Controller::Admin::Themes - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 themes

Controller for admin 'themes' page

=cut

sub themes : Path : Args(0) {
    my ( $self, $c ) = @_;

    my @themes = $c->model('SubMan::Theme')->search( {}, {order_by => {-asc => 'id'}} )->all;

    $c->stash( {themes => \@themes} );

    return;
}

=head2 add_theme

Controller for admin 'Add theme' page

=cut

sub add_theme : Local : Args(0) {
    my ( $self, $c ) = @_;

    return unless $c->req->param;

    my @alerts = ();
    $c->stash( {alerts => \@alerts} );

    my $theme_name = lc $c->req->param('name');
    $theme_name =~ s/[\s_]/-/g;
    $theme_name =~ s/[^0-9a-z\-]//g;

    # version folder if same name exists
    my $count = 1;
    while ( -r $c->path_to( 'root', 'static', 'themes', $theme_name ) ) {
        if ( $theme_name =~ /\.\d+$/ ) {
            $theme_name =~ s/\d+$/$count/;
        }
        else {
            $theme_name .= '.' . $count;
        }
        $count++;
    }

    my $theme_folder = $c->path_to( 'root', 'static', 'themes', $theme_name );

    try {
        mkdir($theme_folder) or die "Can't create directory $theme_folder";

        my $css_file = $c->req->upload('css_file');
        $css_file->copy_to( $theme_folder . '/style.css' );

        my $image_stream = $c->req->param('photo_input');
        if ( $image_stream =~ /(.*?)\s*base64,\s*(.*)$/m ) {
            $image_stream = $2;
        }

        my $decoded = MIME::Base64::decode_base64($image_stream);
        open my $fh, '>', $theme_folder . '/thumb.png' or die $!;
        binmode $fh;
        print $fh $decoded;
        close $fh;
    }
    catch {
        $c->logger->error("Unable save theme $theme_folder: $_");
        $c->alert( {error => "Unable save theme $theme_folder: $_"} );
        remove_tree( $theme_folder, {error => \my $error} );
        return;
    } or return;

    # only one theme can be active
    if ( $c->req->param('active') ) {
        $c->model('SubMan::Theme')->search()->update( {active => 0} );
    }

    try {
        $c->model('SubMan::Theme')->create(
            {   name       => $c->req->param('name'),
                css_file   => $theme_name . '/style.css',
                image_file => $theme_name . '/thumb.png',
                active     => $c->req->param('active') ? 1 : 0,
            }
        );
        $c->logger->info("Theme ($theme_name) created successfully.");
        $c->alert( {success => q/The theme '/ . $c->req->param('name') . q/' was created./} );
    }
    catch {
        $c->logger->error("Unable to create theme : $_");
        $c->alert( {error => 'The theme could not be created. ' . 'Please check the error log for more details.'} );
        return;
    } or return;
}

=head2 delete_theme

Controller for admin delete theme action

=cut

sub delete_theme : Local : Args(1) {
    my ( $self, $c ) = @_;

    return $c->response->redirect('/admin/themes') if ( $c->request->arguments->[0] == 1 );

    my $theme = $c->model('SubMan::Theme')->find( {id => $c->request->arguments->[0]} );

    my ($theme_name) = $theme->css_file =~ /(.+?)\//;
    my $theme_folder = $c->path_to( 'root', 'static', 'themes', $theme_name );

    try {
        remove_tree( $theme_folder, {error => \my $error} );
        die "Can't remove folder $theme_folder" if -e $theme_folder;
        $theme->delete;
    }
    catch {
        $c->logger->error("Unable to delete folder $theme_folder: $_");
        return;
    } or return;

    return $c->response->redirect('/admin/themes');
}

=head2 activate

Controller for admin activate theme action

=cut

sub activate : Local : Args(0) {
    my ( $self, $c ) = @_;

    $c->model('SubMan::Theme')->search()->update( {active => 0} );

    $c->model('SubMan::Theme')->find( {id => $c->req->param('theme_id')} )->update( {active => 1} );

    return $c->response->redirect('/admin/themes');
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
