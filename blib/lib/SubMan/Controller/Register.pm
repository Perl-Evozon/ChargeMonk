package SubMan::Controller::Register;
use Moose;
use Module::Load;
use namespace::autoclean;

use SubMan::Helpers::Gateways::Details;

use SubMan::Helpers::Gateways::Authorize;
use SubMan::Helpers::Gateways::Braintree;
use SubMan::Helpers::Gateways::Stripe;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

SubMan::Controller::Register - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

Subscription registration page

=cut

sub index : Path('/register') : Args(2) : Public {
    my ( $self, $c ) = @_;

    $c->forward( 'SubMan::Controller::Register::Wizard', 'step_1', [$c->req->args->[0], $c->req->args->[1]] );

    return;
}

sub activate_email : Path('/activate_email') : Args(0) : Public {
    my ( $self, $c ) = @_;

    return unless $c->req->param;

    my $registration_token =
        $c->model('SubMan::UserRegistrationToken')->search( {token => $c->req->param('token')} )->single;

    # TODO: Return message if no token

    if ($registration_token) {
        my $link_user_subscription =
            $c->model('SubMan::LinkUserSubscription')->find( {id => $registration_token->link_user_subscription_id} );

        return $c->response->redirect( '/register/step-2/subscription/'
                . $link_user_subscription->subscription_id
                . '?token='
                . $c->req->param('token') );
    }

    return $c->response->redirect('/');
}

sub complete_registration : Local : Args(0) : Public {
    my ( $self, $c ) = @_;

    return unless $c->req->param;

    my $registration_token =
        $c->model('SubMan::UserRegistrationToken')->search( {token => $c->req->param('registration_token')} )->single;
    if ( $registration_token ) {        
        my $link_subscription = $c->model('SubMan::LinkUserSubscription')->find($registration_token->link_user_subscription_id());        
        my $amount = $link_subscription->amount_with_discount() || $link_subscription->subscription->price();
        
        my $gateway = SubMan::Helpers::Gateways::Details::get_active_gateway;
        my $gateway_credentials = SubMan::Helpers::Gateways::Details::get_gateway_credentials( $c, $gateway );
        $gateway = 'SubMan::Helpers::Gateways::' . ucfirst($gateway);
        my $active_gateway = $gateway->new(
            args => {
                c                          => $c,
                gateway_credentials        => $gateway_credentials,
                credit_card                => $c->session->{'cc'},
                link_user_subscription_id  => $registration_token->link_user_subscription_id,
                amount                     => $amount,
            }
        );

        $active_gateway->add_user_and_pay();
        
        $c->alert({'success' => 'Payment completed successfully for '.$registration_token->link_user_subscription_id} ) if ( !$c->has_errors() );
        $registration_token->delete if $registration_token;
    } else {
        $c->alert( {'error' => 'Details have already been submitted'} );
    }

    $c->stash({
        template => 'register/result.tt',
    });
    
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;
