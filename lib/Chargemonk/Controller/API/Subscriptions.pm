package Chargemonk::Controller::API::Subscriptions;

use Digest::MD5 qw(md5_base64);
use Moose;
use namespace::autoclean;
use Try::Tiny;
use JSON::XS;
use DateTime;
use Storable qw( dclone );

BEGIN { extends 'Chargemonk::Controller::API::Base' }

use Chargemonk::Helpers::Visitor::Registration;
use Chargemonk::Helpers::Gateways::Authorize;
use Chargemonk::Helpers::Gateways::Braintree;
use Chargemonk::Helpers::Gateways::Stripe;

=head1 NAME

Chargemonk::API::Base - Base class for the API 

=head1 DESCRIPTION

Chargemonk API
    returns JSON by default
=cut

#sub test : Local : ActionClass('REST') { }


=head2 login
    
    Login user and create a session token
    
=cut

sub login : Local {
    my ( $self, $c ) = @_;

    if ( $c->authenticate( {email => $c->req->param('email'), password => $c->req->param('password')} ) ) {
        $c->change_session_expires(86400) if $c->req->param('remember');
        $self->status_ok(
            $c,
            entity => {
                success       => 'ok',
                user_id       => $c->user->id(),
                session_id    => $c->sessionid(),
                user_type     => $c->user->type(),
                subscriptions => {}
            }
        );
    }
    else {
        $self->status_ok( $c, entity => {error => 'Invalid login'} );
    }

    $c->detach();
}


=head2 logout
    
    Logout
    
=cut

sub logout : Local : Public {
    my ( $self, $c ) = @_;

    if ( $c->session() ) {
        $c->logout();
        $self->status_ok( $c, entity => {message => 'Logged out',} );
    }
    else {
        $self->status_ok( $c, entity => {error => 'Not logged in'} );
    }

    $c->detach();
}


=head2 register
    
    Register new user
    
=cut

sub register : Local : Public {
    my ( $self, $c ) = @_;

    my $existing_user = $c->model('Chargemonk::User')->search( {email => $c->req->params->{email}} )->first();
    if ($existing_user) {
        $self->status_ok( $c, entity => {error => 'Email already exists.'} );
        $c->detach();
    }
    my $subscription = $c->model('Chargemonk::Subscription')->find( {id => $c->req->params->{sid}} );
    my @features = $c->model('Chargemonk::LinkSubscriptionFeature')->search( {subscription_id => $subscription->id} )->all;

    my @cols = qw(
        email password firstname lastname address address2 country state zip_code phone gender
        company_name company_address company_country company_zip_code company_phone
    );

    my $user_hash;
    map { $user_hash->{$_} = $c->req->params->{$_} || undef } @cols;
    $user_hash->{type} = 'LEAD';

    my $user_rs;
    eval { $user_rs = $c->model('Chargemonk::User')->create($user_hash); };
    if ($@) {
        $self->status_ok( $c, entity => {error => 'Could not register user. Please try again later'} );
        $c->detach();
    }
    my $active_from_date = DateTime->now();
    my $date_object      = dclone($active_from_date);
    my $active_to_date =
        $date_object->add( days => ( $c->req->params->{trial} ) ? $subscription->trial_period : $subscription->period );

# TODO: change the active_from_date and active_to_date to use the subscription params, not the ones from request
    my $link_user_subscription = $c->model('Chargemonk::LinkUserSubscription')->create(
        {   user_id          => $user_rs->id,
            subscription_id  => $subscription->id,
            active_from_date => $active_from_date->strftime("%Y-%m-%d"),
            active_to_date   => $active_to_date->strftime("%Y-%m-%d"),
        }
    );

# mark the discount as used, if any code validated previously
    if ( my $dc = $c->req->param('discount_code') ) {
        my $code = $c->model('Chargemonk::Code')->search( {code => $dc} )->first();
        $code->update( {user_id => $user_rs->id, redeem_date => DateTime->now()} );
    }

    Chargemonk::Helpers::Visitor::Registration::send_register_user_email(
        {   c                         => $c,
            user_id                   => $user_rs->id,
            link_user_subscription_id => $link_user_subscription->id,
            email                     => $c->req->params->{email},
            email_page_return         => $c->req->params->{email_page_return},
            trial                     => $c->req->params->{trial},
            flow_type                 => 'individual'
        }
    );
    
    $self->status_ok( $c,
        entity =>
            {success => 'Details completed successfuly. Please verify your email to complete the registration process'}
    );

    $c->detach();
}


=head2 register
    
    Register new user
    
=cut

sub payment : Local : Public {
    my ( $self, $c ) = @_;
    
    return unless $c->req->params;
    my @alerts = ();

    my $registration_token =
        $c->model('Chargemonk::UserRegistrationToken')->search( {token => $c->req->params->{token}} )->single;
    if ( $registration_token ) {        
        my $link_subscription = $c->model('Chargemonk::LinkUserSubscription')->find($registration_token->link_user_subscription_id());        
        my $amount = $link_subscription->amount_with_discount() || $link_subscription->subscription->price();
        
        my $gateway = Chargemonk::Helpers::Gateways::Details::get_active_gateway;
        my $gateway_credentials = Chargemonk::Helpers::Gateways::Details::get_gateway_credentials( $c, $gateway );
        $gateway = 'Chargemonk::Helpers::Gateways::' . ucfirst($gateway);
        my $active_gateway = $gateway->new(
            args => {
                c                          => $c,
                gateway_credentials        => $gateway_credentials,
                credit_card                => $c->req->params(),
                link_user_subscription_id  => $registration_token->link_user_subscription_id,
                alerts                     => \@alerts,
                amount                     => $amount,
            }
        );

        $active_gateway->add_user_and_pay();
        
        ( !scalar @alerts ) ? $self->status_ok( $c, entity => { success => "Payment completed successfully" } )
                            : $self->status_ok( $c, entity => { error => "There has been an error while processing the data. Please contact support" } );
        $registration_token->delete if $registration_token;
    } else {
        $self->status_ok( $c, entity => {'error' => 'Details have already been submitted'} );
    }

    $c->detach();
}

sub user_details : Local : Public {
    my ( $self, $c ) = @_;

    if ( my $email = $c->req->param('email') ) {
        my $user = $c->model('Chargemonk::User')->search( {email => $email} )->first();

        if ($user) {
            $self->status_ok(
                $c,
                entity => {
                    user_id       => $user->id(),
                    email         => $user->email(),
                    subscriptions => {},
                }
            );
        }
        else {
            $self->status_ok( $c, entity => {error => 'Could not find user:' . $email} );
        }
    }
    else {
        $self->status_ok( $c, entity => {error => 'email not provided'} );
    }

    $c->detach();
}


=head1 AUTHOR

Ovidiu

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
