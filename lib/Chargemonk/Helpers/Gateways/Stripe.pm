package Chargemonk::Helpers::Gateways::Stripe;
use Business::Stripe;

use Moose;
use Try::Tiny;

=head1 NAME

Chargemonk::Helpers::Gateways::Stripe- Helpers for Chargemonk payment gateway implemented with stripe

=head1 DESCRIPTION

Chargemonk helpers for admin actions available on 'User Details' page.

=head1 METHODS

=cut


=head2
    Arguments necessary to create the object:
        args => {
            c                          => $c
            gateway_credentials        => $gateway_credentials, #( Chargemonk::Helpers::Gateways::Details::get_gateway_credentials( $c, $gateway ) )
            credit_card                => $c->session->{cc}, # optional - only when creating a new customer
            link_user_subscription_id  => $link_user_subscription_id,
            alerts                     => [ @alerts ],
            amount                     => $amount #optional - default value is $subscription->price
        }
=cut

has args => (
    is       => 'rw',
    isa      => 'Maybe[HashRef]',
    required => 1
);

has add_user_and_pay => (
    is      => 'ro',
    builder => '_add_user_and_pay',
    lazy    => 1
);

has pay => (
    is      => 'ro',
    builder => '_pay',
    lazy    => 1
);

has delete_user => (
    is      => 'ro',
    builder => '_delete_user',
    lazy    => 1
);

=head2
    _initialize_gateway
    Retrieves data for link_user_subscription
        DBiX objects:
        - $self->{args}->{link_user_subscription}
        - $self->args->{user}
        - $self->args->{subscription}
    Authenticates merchant gateway credentials
=cut

sub _initialize_gateway {
    my $self = shift;

    my $c = $self->args->{c};

    $self->args->{link_user_subscription} =
        $c->model('Chargemonk::LinkUserSubscription')->find( {id => $self->args->{link_user_subscription_id}} );
    $self->args->{user} = $c->model('Chargemonk::User')->find( {id => $self->args->{link_user_subscription}->user_id} );
    $self->args->{subscription} =
        $c->model('Chargemonk::Subscription')->find( {id => $self->args->{link_user_subscription}->subscription_id} );

    my $gateway_credentials = $self->args->{gateway_credentials};
    $self->args->{gateway} = Business::Stripe->new( -api_key => $gateway_credentials->{'secret_key'} );
}

=head2
    _add_user_and_pay
    Builder method for the add_user_and_pay Moose component.
    Performs addition of new user to stripe sandbox and payment
    request from this user
=cut

sub _add_user_and_pay {
    my $self = shift;

    $self->_initialize_gateway();

    my $customer = $self->args->{c}->model('Chargemonk::StripeUser')->find( {user_id => $self->args->{user}->id} );
    $self->args->{customer_id} = ($customer) ? $customer->customer_id : $self->_add_customer_with_card();

    return unless ( $self->args->{customer_id} );

    $self->_charge_card();
}

=head2
    _pay
    Builder method for the pay Moose component.
    Generates a payment request from an existing profile
=cut

sub _pay {
    my $self = shift;

    my $c = $self->args->{c};

    $self->_initialize_gateway();

    my $customer = $c->model('Chargemonk::StripeUser')->find( {user_id => $self->args->{user}->id} );
    $self->args->{customer_id} = $customer->customer_id if ($customer);

    $self->_charge_card();
}

=head2
    _add_customer_with_card
    Helper method to add new account to stripe sandbox
=cut

sub _add_customer_with_card {
    my $self = shift;

    my $args = $self->args;
    my $c    = $args->{c};

    my $customer_id = $args->{gateway}->customers_create(
        card        => $args->{credit_card}->{stripeToken},
        email       => $args->{user}->email,
        description => $args->{user}->id
    );

    if ($customer_id) {
        my $card_token = $args->{gateway}->success->{default_card};
        $c->logger->info(
            sprintf(
                "Customer id ( %d ) was succesfully added to vault with credit card( %s )",
                $args->{user}->id, $card_token
            )
        );
        my $card_info = $args->{gateway}->success->{cards}->{data}->[0];
        try {
            $c->model('Chargemonk::StripeUser')->create(
                {   customer_id     => $customer_id,
                    card_token      => $card_token,
                    user_id         => $args->{user}->id,
                    card_type       => $card_info->{type},
                    last_four       => $card_info->{last4},
                    expiration_date => join( '-', $card_info->{exp_year}, $card_info->{exp_month}, '01' )
                }
            );
        }
        catch {
            $c->logger->error(
                sprintf(
                    "Unable to save user ( %d ) and credit card( %s ) to the Stripe table: %s",
                    $args->{user}->id, $args->{credit_card}->{stripeToken}, $_
                )
            );
        };

        return $customer_id;
    }
    else {
        try {
            $c->model('Chargemonk::Transaction')->create(
                {   user_id                   => $args->{user}->id,
                    link_user_subscription_id => $args->{link_user_subscription}->id,
                    gateway                   => "stripe",
                    amount                    => $args->{subscription}->price,
                    action                    => 'save_customer',
                    response_text             => $args->{gateway}->error->{message}
                }
            );
        }
        catch {
            $c->logger->error(
                sprintf(
                    "Unable to save failed customer( %d ) creation to the Transaction table : %s",
                    $args->{user}->id, $_
                )
            );
        };

        $c->alert(
            {'error' => 'Payment failed:' . $args->{gateway}->error->{message}},
            sprintf(
                "Customer id ( %d ) failed to be added to the vault: %s",
                $args->{user}->id, $args->{gateway}->error->{message}
            )
        );
        return;
    }
}


=head2
    _delete_user
    Builder method for the delete_user Moose component.
    Deletes user from stripe sandbox
=cut

sub _delete_user {
    my $self = shift;

    my $c = $self->args->{c};

    $self->_initialize_gateway();

    my $customer = $c->model('Chargemonk::StripeUser')->find( {user_id => $self->args->{user}->id} );
    my $response = $self->args->{gateway}->customers_delete( $customer->customer_id . "d" );

    return $response;
}

=head2
    _charge_card
    Generates payment from an existing
    or new profile
=cut

sub _charge_card {
    my $self = shift;

    my $args = $self->args;
    my $c    = $args->{c};

    my $charge_ammount = $args->{amount} || $args->{subscription}->price;

    if ( !$charge_ammount ) {
        try {
            $c->model('Chargemonk::Invoice')->create(
                {   invoice_id                => 0,
                    user_id                   => $args->{user}->id,
                    link_user_subscription_id => $args->{link_user_subscription}->id,
                    gateway                   => "stripe",
                    charge                    => 0,
                }
            );
        }
        catch {
            $c->logger->error(
                sprintf( 'Unable to save invoice for client( %d ) to the <Invoice> table : %s', $args->{user}->id, $_ )
            );
            return;
        } or return;

        $args->{link_user_subscription}->update( {'active' => '1'} );
        return;
    }

    my $transaction_id = $args->{gateway}->charges_create(
        customer => $args->{customer_id},
        amount   => sprintf( "%d00", $charge_ammount ),
        currency    => 'USD',  #not all curencies are available depending on stripe country ..... hardcoding USD for now
        description => sprintf(
            "Subscription to %s costing %d %s",
            $args->{subscription}->name,
            $charge_ammount, $args->{subscription}->currency
        )
    );

    if ($transaction_id) {
        $c->logger->info(
            sprintf(
                "Customer id ( %d ) has succesfully paid for link_user_subscription( %d ) having
                the transaction_id( %s )", $args->{user}->id, $args->{link_user_subscription}->id, $transaction_id
            )
        );

        try {
            $c->model('Chargemonk::Invoice')->create(
                {   invoice_id                => $transaction_id,
                    user_id                   => $args->{user}->id,
                    link_user_subscription_id => $args->{link_user_subscription}->id,
                    gateway                   => "stripe",
                    charge                    => $args->{subscription}->price,
                }
            );
        }
        catch {
            $c->logger->error(
                sprintf(
                    "Unable to save invoice ( %s ) for client( %d ) to the Invoice table : %s",
                    $transaction_id, $args->{user}->id, $_
                )
            );
        };

        $args->{link_user_subscription}->update( {'active' => '1'} );

        return 1;
    }
    else {
        $c->alert( {'error' => 'Payment failed:' . $args->{gateway}->error->{message}},
            sprintf( "Payment failed for customer( %d ): %s", $args->{user}->id, $args->{gateway}->error->{message} ) );

        try {
            $c->model('Chargemonk::Transaction')->create(
                {   user_id                   => $args->{user}->id,
                    link_user_subscription_id => $args->{link_user_subscription}->id,
                    gateway                   => "stripe",
                    amount                    => $charge_ammount,
                    action                    => 'save_payment',
                    response_text             => $args->{gateway}->error->{message}
                }
            );
        }
        catch {
            $c->logger->error(
                sprintf(
                    "Unable to save failed transaction for client( %d ) to the Transaction table : %s",
                    $args->{user}->id, $_
                )
            );
        };
        return 0;
    }
}

__PACKAGE__->meta->make_immutable;

1;
