package Chargemonk::Helpers::Gateways::Details;

use YAML::Tiny;
use Data::Dumper;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(get_active_gateway get_gateway_credentials);

=head1 NAME

Chargemonk::Helpers::Gateways::Details- Helpers for Chargemonk gateway information

=head1 DESCRIPTION

Chargemonk helpers for retrieving gateway information details

=head1 METHODS

=cut


=head2 get_active_gateway

    Helper for retrieving the active payment gateway

=cut

sub get_active_gateway {

    my $yaml = YAML::Tiny->new;
    $yaml = YAML::Tiny->read('conf/gateway.yaml');

    return $yaml->[0]->{'default'};
}

=head2 get_gateway_credentials

    Helper for retrieving all parameters for a particular gateway name from the conf/gateway.yaml file

=cut

sub get_gateway_credentials {
    my ( $c, $gateway ) = @_;

    my $yaml = YAML::Tiny->new;
    $yaml = YAML::Tiny->read('conf/gateway.yaml');

    if ( $yaml->[0]->{'gateways'}->{$gateway} ) {
        return $yaml->[0]->{'gateways'}->{$gateway};
    }
    else {
        $c->logger->error("Bad gateway name. The name $gateway does not exist in the config file");
    }

}

1;
