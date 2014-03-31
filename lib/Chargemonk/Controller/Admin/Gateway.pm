package Chargemonk::Controller::Admin::Gateway;
use Moose;
use namespace::autoclean;

use YAML::Tiny;

BEGIN { extends 'Chargemonk::Controller::Authenticated'; }

=head1 NAME

Chargemonk::Controller::Admin::Gateway - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 gateway

Controller for admin 'Gateway' page

=cut

sub gateway :Path :Args() {
    my ( $self, $c ) = @_;

    my @alerts = ();
    my $pretty_name;
    my $yaml = YAML::Tiny->new;
    $yaml = YAML::Tiny->read('conf/gateway.yaml');

    $c->stash({ data => $yaml->[0] });
    
    return unless $c->req->param;
    
    if ($c->req->param('selected_gateway')) {
        $pretty_name = $c->req->param('selected_gateway');
        $pretty_name =~ s/_/ /;
    }
    
    if ($yaml->[0]->{'gateways'}->{$pretty_name}) {
        $yaml->[0]->{'default'} = $pretty_name;
        $yaml->write('conf/gateway.yaml');
        push(@alerts,{success => 'Changed default Payment Gateway'});
    }else {
        push(@alerts,{error => 'Bad gateway name'});
    }

    $c->stash({ alerts  => \@alerts });
}

=head2 edit

Controller for admin 'Gateway' page that changes a gateway configuration parameters

=cut

sub edit :Local  {
    my ( $self, $c ) = @_;

    my @alerts = ();
    my $params = $c->req()->params();
    my $pretty_name;
    my $gateway_name;
    
    my $yaml = YAML::Tiny->new;
    $yaml = YAML::Tiny->read('conf/gateway.yaml');
    
    if ($params->{'name'}) {
        $pretty_name = $params->{'name'};
        $pretty_name =~ s/_/ /;
    }
    
    if ($yaml->[0]->{'gateways'}->{$pretty_name}) {
        $gateway_name = delete $params->{'name'};
        $yaml->[0]->{'gateways'}->{$pretty_name} = $params;
        $yaml->write('conf/gateway.yaml');
        push(@alerts, {success => 'Gateway details successfully updated.'});
    } else {
        push(@alerts,{error => 'Bad gateway name'});
    }

    $c->stash({
            credentials    => $params,
            gateway_name => $gateway_name,
            alerts  => \@alerts,
            });
}
=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') { }

=head1 AUTHOR

mar_k

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
