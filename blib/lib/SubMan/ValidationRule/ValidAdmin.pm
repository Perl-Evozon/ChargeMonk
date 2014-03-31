package SubMan::ValidationRule::ValidAdmin;

use strict;
use warnings;

use base 'SubMan::ValidationRule::Base';

=head1 NAME

SubMan::ValidationRule::NotEmpty - Validates for empty params

=head1 DESCRIPTION

This class validates that a value is not empty

See C<<SubMan::ValidationRule::Base>> for more details

=head1 SYNOPSYS

From a controller, before an action :

    __PACKAGE__->validation_rules('edit' => {
                subject      => [ NotEmpty => 'Title cannot be empty!' ],
    });
    
    sub edit :Local { ... }

=head1 METHODS

=head1 validate_scalar

Validates that a scalar is not empty

=cut

sub validate_scalar {
    my ( $self, $param_name, $value ) = @_;

    if ( defined $value ) {
        my $user_id = $self->{c}->req->args->[0];
        my $link_user_subscription =
            $self->{c}->model('SubMan::LinkUserSubscription')->search( {user_id => $user_id} )->first();

        my $admin_incompatible = ( $link_user_subscription ? 1 : 0 );
        if ($admin_incompatible) {
            push @{$self->{c}->stash->{alerts}}, {'error' => "The current user cannot be set as 'ADMIN'."};
            $self->{c}->logger->error( "Attempt to make user '"
                    . $user_id
                    . "' ADMIN although it is incompatible for this.(has linked subscriptions)" );
        }

        return $admin_incompatible ? 0 : 1;
    }


    return 1;
}

1;
