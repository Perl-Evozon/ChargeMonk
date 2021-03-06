package SubMan::Controller::API::Payment;

use Moose;
use namespace::autoclean;

BEGIN { extends 'SubMan::Controller::Authenticated' }

use SubMan::Helpers::Gateways::Details;

=head1 NAME

SubMan::Controller::Payment

=head1 METHODS

=head2 index
=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    #Cross domain access
    $c->response->headers->header( 'Access-Control-Allow-Origin' => '*' );
    
    return 1;
}

sub index : Path('/api/payment') : Public {
    my ( $self, $c ) = @_;

    my $gateway = SubMan::Helpers::Gateways::Details::get_active_gateway;
    my $gateway_credentials = SubMan::Helpers::Gateways::Details::get_gateway_credentials( $c, $gateway );
    
    my $template =
          $gateway eq 'braintree' ? 'api/payment/braintree.tt'
        : $gateway eq 'stripe'    ? 'api/payment/stripe.tt'
        : $gateway eq 'authorize' ? 'api/payment/authorize.tt'
        :                           '';

    my $link_user_subscription = $c->model('SubMan::LinkUserSubscription')->find( $c->req->params->{lusid} );

    $c->stash(
        template             => $template,
        subscription         => $link_user_subscription->subscription(),
        token                => $c->req->params->{token},
        finish_register_page => $c->req->params->{finish_register_page_return},
        gateway_credentials  => $gateway_credentials
    );
}

__PACKAGE__->meta->make_immutable;

1;
