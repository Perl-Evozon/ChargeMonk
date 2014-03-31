package Chargemonk::ValidationRule::Subscription::DiscountCodeNotUsed;

use strict;
use warnings;

use base 'Chargemonk::ValidationRule::Base';

=head1 NAME

Chargemonk::ValidationRule::DiscountCode - Validates discount codes

=head1 DESCRIPTION

This class checks if a discount code is already used

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
    my ($self,$param_name,$value) = @_;

    # only check if discount code sent
    return 1 if (not $value);

    my $code = $self->{c}->model('Chargemonk::Code')->search( { 'code' =>  $value } )->first();
    
    return (defined $code && $code->redeem_date()) ? 0 : 1;
}

1;