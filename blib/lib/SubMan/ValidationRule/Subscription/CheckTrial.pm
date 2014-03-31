package SubMan::ValidationRule::Subscription::CheckTrial;

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
    my ($self,$param_name,$value) = @_;
    
    if ( $self->{c}->req->params->{has_trial} && $self->{c}->req->params->{access_type} ) {
        return ( defined $param_name && $value ne '' ) ? 1 : 0;
    }
    
    return 1;
}

1;