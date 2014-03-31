package Chargemonk::ValidationRule::Base;

=head1 NAME

Chargemonk::ValidationRule::Base - Base class for all validators

=head1 new

Creates a new validator using the given arguments

At least "message" param must be present

=cut
sub new {
    my ($class,%params) = @_;
    
    die "Validator $class needs a 'message' argument!" unless $params{message};

    my $self = \%params;

    bless $self,$class;

    return $self;
}

=head2 validate

Called with one argument, the value to be validated.

Returns true/false, depending on weather the validation failed or not

=cut
sub validate {
    my ($self,$param,$value) = @_;

    my $class = ref($self);

    if ( ! ref($value) ) {
        die "$class cannot validate scalars!" unless $class->can('validate_scalar');
        return $self->validate_scalar($param,$value);
    }
}

=head2 error

Returns the error message that was set for this validator

=cut
sub error {$_[0]->{message} };

1;