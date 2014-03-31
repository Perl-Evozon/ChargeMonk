package SubMan::Controller::Authenticated;

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

=head1 NAME

SubMan::Controller::Authenticated - base controller for all other SubMan controllers that need authentication

This module should be used instead of Catalyst::Controller as base for
all SubMan controllers that need authentication

=head1 METHODS

=head2 begin

Check that the user is logged in - Cut the request flow otherwise.

=cut

sub begin : Private {
    my ( $self, $c ) = @_;

=cut
    TODO:
    This needs to be thinked so we can
    cover all cases in which authentication
    is not needed
=cut

    my $attributes = $c->action()->attributes();

    return 1
        if ( exists $attributes->{Public}
        || ( $c->session && $c->user )
        || ( $c->req->params->{email} && $c->req->params->{password} && $c->action =~ /login/i ) );

    $c->response->redirect("/index.html");
    $c->detach();
}

=head2 auto :Private
    Private auto method that implements authorisation
=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    my $theme = $c->model('SubMan::Theme')->search( {'active' => 1} )->single;

    if ($theme) {
        $c->stash( {default_theme => {id => $theme->id, css_file => $theme->css_file}} );
    }

    $self->_validate($c);

    return 1;
}

#Hash containing all the validation rules for each class
my %validation_rules;


sub validation_rules {
    my ( $class, %rules ) = @_;

    $validation_rules{$class} = {%{$validation_rules{$class} || {}}, %rules};

}

sub _validate : Private {
    my ( $self, $c ) = @_;

    my $params = $c->req->params();
    my $action = $c->action->name();

    my %rules = %{$validation_rules{$c->action->class()}{$action} // {}};

    my %errors = ();

    foreach my $param ( keys %rules ) {
        my $count = 0;
        while ( $count < scalar @{$rules{$param}} ) {
            my $validator_class = sprintf( "SubMan::ValidationRule::%s", $rules{$param}[$count++] );
            my $params = $rules{$param}[$count++];

            eval "use $validator_class";

            if ($@) {
                $c->log->warn("Unknown validator $validator_class");
                next;
            }

            my $validator;
            if ( ref($params) eq "HASH" ) {
                $validator = $validator_class->new( %{$params}, c => $c );
            }
            else {
                $validator = $validator_class->new( message => $params, c => $c );
            }

            if ( !$validator->validate( $param, $c->req->param($param) ) ) {
                $errors{$param} //= [];    #make sure we don't get undefined warnings
                push @{$errors{$param}}, $validator->error();
            }
        }
    }

    my $attr = $c->action->attributes();

    # form_data is used to put the values for a form
    # if is set, the form components could handle and set values to each form fields
    $c->stash( form_data => $params );

    if ( scalar( keys %errors ) ) {
        $c->stash( errors => \%errors );
        if ( defined $attr->{OnError} ) {
            $c->go( $c->action->class(), $attr->{OnError}[0] );
        }
        else {
            $c->go( "Root", "unexpected_error" );
        }
    }
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;

    return if ( $c->response->body || $c->response->status != 200 );

    my $attributes = $c->action()->attributes();

    if ( exists $attributes->{JSON} ) {    #marks actions that return JSON response
        $c->forward( $c->view("JSON") );
    }
    else {
        $c->forward( $c->view("HTML") );
    }
}

__PACKAGE__->meta->make_immutable;

1;
