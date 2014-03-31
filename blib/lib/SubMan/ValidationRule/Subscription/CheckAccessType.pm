package SubMan::ValidationRule::Subscription::CheckAccessType;

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
    
    
    
    if ( $self->{c}->req->params->{access_type} ) {
        my $checked_params = {
            period => sub {
                foreach ( 'period', 'period_unit', 'price', 'currency', 'call_to_action' ) {
                    return 0 if( $param_name eq $_ && !$value );
                }            
                return 1;
            },
            period_users => sub {
                foreach ( 'period', 'period_unit', 'price', 'currency', 'call_to_action', 'min_active_period_users', 'max_active_period_users' ) {
                    return 0 if( $param_name eq $_ && !$value );
                }            
                return 1;
            },
            resources => sub {
                foreach ( 'period', 'period_unit', 'price', 'currency', 'call_to_action', 'resource_type', 'min_resource_quantity', 'max_resource_quantity' ) {
                    return 0 if( $param_name eq $_ && !$value );
                }            
                return 1;
            },
            IP_range => sub {
                foreach ( 'period', 'period_unit', 'price', 'currency', 'call_to_action', 'min_active_ips', 'max_active_ips' ) {
                    return 0 if( $param_name eq $_ && !$value );
                }            
                return 1;
            },
            API_calls => sub {
                foreach ( 'period', 'period_unit', 'price', 'currency', 'call_to_action', 'api_calls_volume' ) {
                    return 0 if( $param_name eq $_ && !$value );
                }            
                return 1;
            }
        };
               
        return ( $checked_params->{$self->{c}->req->params->{access_type}}->() ) ? 1 : 0;
    }
    
    return 1
}

1;