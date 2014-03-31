package Chargemonk::Controller::Admin::SubscriptionGroups;

use Moose;
use namespace::autoclean;
use URI;
use Try::Tiny;

BEGIN { extends 'Chargemonk::Controller::Authenticated'; }

=head1 NAME

Chargemonk::Controller::Admin::SubscriptionGroups - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 features

Add new group

=cut

sub add_group : Local {
	my ( $self, $c ) = @_;

	# the admin wants to add a new subscription group
	if ( $c->req->param('name') ) {
		try {
			$c->model('Chargemonk::SubscriptionGroup')->create( {name => $c->req->param('name')} );

			$c->alert( {success => 'The subscription group  \'' . $c->req->param('name') . '\' was created.'} );
			$c->logger->info( sprintf( "Created the subscription group '%s'.", $c->req->param('name') ) );
		}
		catch {
			$c->alert( {error => 'The group could not be created. Please check the error log for more details.'} );
			$c->logger->error( "Could not create subscription group '" . $c->req->param('name') . "' : $_" );
			return;
		} or return;
	}
	else {
		$c->alert( {error => 'No group name was provided'} );
		$c->logger->error("Attempt to create a subscription group without providing the group name.");
	}
}


=head2 features

Delete group

=cut

sub delete_group : Local {
	my ( $self, $c ) = @_;

	if ( $c->req->param('id') ) {
		my $gr = $c->model('Chargemonk::SubscriptionGroup')->find( $c->req->param('id') );
		if ($gr) {
			try {
				$gr->delete();

				$c->alert( {success => 'The subscription group \'' . $gr->name . '\' was deleted.'} );
				$c->logger->info( sprintf( "Deleted the subscription group '%s'.", $gr->name ) );
			}
			catch {
				$c->alert( {error => 'The group could not be deleted. Please check the error log for more details.'} );
				$c->logger->error( "Could not delete subscription group '" . $gr->name . "' : $_" );
				return;
			} or return;
		}
		else {
			$c->alert(
				{   error =>
						'The group you are trying to delete does not exist. Please check the error log for more details.'
				}
			);
			$c->logger->error(
				"Attempt to remove a group id wich does not exist. (id = " . $c->req->param('id') . ")." );
		}
	}
}


=head2 features

Delete group

=cut

sub edit_group : Local {
	my ( $self, $c ) = @_;

	my $alerts = [];

	if ( $c->req->param('id') ) {
		my $gr = $c->model('Chargemonk::SubscriptionGroup')->find( $c->req->param('id') );
		if ($gr) {
			my $old_name = $gr->name;
			try {
				$gr->update( {name => $c->req->param('name')} );

				$c->alert(
					{         success => 'The subscription group \''
							. $old_name
							. '\' was renamed to \''
							. $c->req->param('name') . '\'.'
					}
				);
				$c->logger->info(
					sprintf(
						" Edited the subscription group '%s' by renaming it to '%s'.",
						$old_name, $c->req->param('name')
					)
				);
			}
			catch {
				$c->alert( {error => 'The group could not be renamed. Please check the error log for more details.'} );
				$c->logger->error(
					"Could not rename subscription group '" . $old_name . "' to '" . $c->req->param('name') . "': $_" );
				return;
			} or return;
		}
		else {
			$c->alert(
				{   error =>
						'The group you are trying to edit does not exist. Please check the error log for more details.'
				}
			);
			$c->logger->error( "Attempt to edit a group id wich does not exist. (id = " . $c->req->param('id') . ")." );
		}
	}

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
