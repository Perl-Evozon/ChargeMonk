package Chargemonk::ValidationRule::UniqueUser;

use strict;
use warnings;

use base 'Chargemonk::ValidationRule::Base';

=head1 NAME

Chargemonk::ValidationRule::NotEmpty - Validates for empty params

=head1 DESCRIPTION

This class validates that a value is not empty

See C<<Chargemonk::ValidationRule::Base>> for more details

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
    my ( $self,$param_name,$value ) = @_;

    my $is_unique = $self->{c}->model('Chargemonk::User')->search( { 'email' =>  $value } )->first() ? 0 : 1;
       
    return $is_unique;
}

1;