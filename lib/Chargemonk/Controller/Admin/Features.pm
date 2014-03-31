package Chargemonk::Controller::Admin::Features;

use Moose;
use namespace::autoclean;
use Try::Tiny;

BEGIN { extends 'Chargemonk::Controller::Authenticated'; }

=head1 NAME

Chargemonk::Controller::Admin::Features - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 features

Controller for admin 'Features' page

=cut

sub features : Path : Args(0) {
	my ( $self, $c ) = @_;

	my @features;
	@features = $c->model('Chargemonk::Feature')->all();

	$c->stash( {features => \@features} );
}

=head2 features

Action for adding a new feature

=cut

sub add_feature : Local : Args(0) {
	my ( $self, $c ) = @_;

	return unless $c->req->param;

	my $feature;
	try {
		$feature = $c->model('Chargemonk::Feature')->create(
			{   name        => $c->req->param('name'),
				description => $c->req->param('description'),
			}
		);
		$c->alert( {'success' => 'The feature was successfuly added'} );
		$c->logger->info('New user feature create');
	}
	catch {
		$c->alert( {'error' => 'Unable to add new feature. Please check the error log for more details.'} );
		$c->logger->error( 'Unable to create feature :' . $_ );
	} or return;
}

=head2 features

Action for editing an existing feature

=cut

sub edit_feature : Local : Args(1) {
	my ( $self, $c ) = @_;

	return unless $c->req->param;

	my $feature_id = $c->request->arguments->[0];
	my $feature    = $c->model('Chargemonk::Feature')->find($feature_id);

	try {
		$feature->update(
			{   name        => $c->req->param('name'),
				description => $c->req->param('description'),
			}
		);

		$c->alert( {'success' => 'The feature was successfuly updated'} );
		$c->logger->info( 'New user created for email ' . $c->req->param('email') . '.' );
	
		$c->stash( {feature => $feature} );
	}
	catch {
		$c->alert( {'error' => 'Unable to update the feature, please make sure that the data is enterd correctly'} );
		$c->logger->error( 'Unable to create user for email :' . $_ );
		return;
	} or return;
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
