package SubMan::ValidationRule::Subscription::DiscountCodeExists;

use strict;
use warnings;

use base 'SubMan::ValidationRule::Base';

=head1 NAME

SubMan::ValidationRule::DiscountCodeExists - Validates discount code

=head1 DESCRIPTION

This class checks if a discount code exists

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
    
    # only check if discount code sent
    return 1 if (not $value);

    my $code_exists = $self->{c}->model('SubMan::Code')->search( { 'code' =>  $value } )->first() ? 1 : 0;
    
    return $code_exists;
}

1;