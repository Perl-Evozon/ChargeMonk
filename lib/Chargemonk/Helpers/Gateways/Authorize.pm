package Chargemonk::Helpers::Gateways::Authorize;
use Business::AuthorizeNet::CIM;

use Moose;
use Try::Tiny;

=head1 NAME

Chargemonk::Helpers::Gateways::AuthorizeNet- Helpers for Chargemonk payment gateway implemented with Authorize.Net

=head1 DESCRIPTION

Chargemonk helpers for admin actions available on 'User Details' page.

=head1 METHODS

=cut

=head2
    Arguments necessary to create the object:
        args => {
            c                          => $c, #required
            gateway_credentials        => $gateway_credentials, #required ( Chargemonk::Helpers::Gateways::Details::get_gateway_credentials( $c, $gateway ) )
            credit_card                => $c->session->{cc}, # optional - only when creating a new customer
            link_user_subscription_id  => $link_user_subscription_id, #required
            alerts                     => [ @alerts ], #optional
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
    $self->args->{gateway} = Business::AuthorizeNet::CIM->new(
        login          => $gateway_credentials->{api_login_id},
        transactionKey => $gateway_credentials->{transaction_key_id},
        test_mode      => $gateway_credentials->{test_mode},
    );

}

=head2
    _add_user_and_pay
    Builder method for the add_user_and_pay Moose component.
    Performs addition of new user to authorize.net sandbox and payment
    request from this user
=cut

sub _add_user_and_pay {
    my $self = shift;

    my $c = $self->args->{c};

    $self->_initialize_gateway();

    my $customer = $c->model('Chargemonk::AuthorizeUser')->find( {user_id => $self->args->{user}->id} );
    $self->args->{customer_profile} =
        ($customer)
        ? $self->args->{gateway}->getCustomerProfile( $customer->customer_id() )
        : $self->_add_customer_with_card();

    return unless $self->args->{customer_profile};

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

    my $customer = $c->model('Chargemonk::AuthorizeUser')->find( {user_id => $self->args->{user}->id} );
    $self->args->{customer_profile} = $self->args->{gateway}->getCustomerProfile( $customer->customer_id() )
        if ($customer);

    $self->_charge_card();
}

=head2
    _add_customer_with_card
    Helper method to add new account to braintree sandbox
=cut

sub _add_customer_with_card {
    my $self = shift;

    my $args = $self->args;
    my $c    = $args->{c};

    my $new_customer = $args->{gateway}->createCustomerProfile(
        merchantCustomerId => $args->{user}->id,
        email              => $args->{user}->email,
        creditCard         => {
            cardNumber     => $args->{credit_card}->{number},
            expirationDate => $args->{credit_card}->{year} . '-' . $args->{credit_card}->{month},
            cardCode       => $args->{credit_card}->{cvv}
        }
    );

    if ( $new_customer->{messages}->{resultCode} eq 'Ok' ) {
        my $new_customer_profile = $args->{gateway}->getCustomerProfile( $new_customer->{customerProfileId} );
        try {
            $c->model('Chargemonk::AuthorizeUser')->create(
                {   user_id     => $args->{user}->id,
                    customer_id => $new_customer_profile->{profile}->{customerProfileId},
                    last_four   => (
                        $new_customer_profile->{profile}->{paymentProfiles}->{payment}->{creditCard}->{cardNumber}
                            =~ /(\d{4})/
                    ) ? $1 : '',
                }
            );
        }
        catch {
            my $customer_id = $new_customer_profile->{profile}->{customerProfileId};
            $c->logger->error( sprintf( "Unable to save user (%d) in <authorize_user> table: %s", $customer_id, $_ ) );
        };

        return $new_customer_profile;
    }
    else {
        try {
            $c->model('Chargemonk::Transaction')->create(
                {   user_id                   => $args->{link_user_subscription}->user_id,
                    link_user_subscription_id => $args->{link_user_subscription}->id,
                    gateway                   => "authorize.net",
                    amount                    => 0,
                    action                    => 'save_customer',
                    response_text             => $new_customer->{messages}->{message}->{text}
                }
            );
        }
        catch {
            $c->logger->error(
                sprintf(
                    "Unable to save failed customer(%d) creation to the Transaction table : %s",
                    $args->{link_user_subscription}->user_id, $_
                )
            );
        };

        $c->alert( {'error' => 'Payment failed, please contact support'},
            "Error while creating Authorize.Net profile:" . $new_customer->{messages}->{message}->{text} );

        return;
    }
}

=head2
    _delete_user
    Builder method for the delete_user Moose component.
    Deletes user from authorize.net sandbox
=cut

sub _delete_user {
    my $self = shift;

    my $c = $self->args->{c};

    $self->_initialize_gateway();

    my $customer = $c->model('Chargemonk::AuthorizeUser')->find( {user_id => $self->args->{user}->id} );
    $self->args->{gateway}->deleteCustomerProfile( $customer->customer_id );
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

    my $amount = $args->{amount} || $args->{subscription}->price;

    if ( !$amount ) {
        try {
            $c->model('Chargemonk::Invoice')->create(
                {   invoice_id                => 0,
                    user_id                   => $args->{link_user_subscription}->user_id,
                    link_user_subscription_id => $args->{link_user_subscription}->id,
                    gateway                   => "authorize.net",
                    charge                    => 0,
                }
            );
        }
        catch {
            $c->logger->error(
                sprintf(
                    'Unable to save invoice for client(%d) to the <Invoice> table : %s',
                    $args->{link_user_subscription}->user_id, $_
                )
            );
            return;
        } or return;

        $args->{link_user_subscription}->update( {'active' => '1'} );
    }
    else {
        my $transaction = $args->{gateway}->createCustomerProfileTransaction(
            'profileTransAuthCapture',
            amount            => $amount,
            customerProfileId => $args->{customer_profile}->{profile}->{customerProfileId},
            customerPaymentProfileId =>
                $args->{customer_profile}->{profile}->{paymentProfiles}->{customerPaymentProfileId}
        );

        if ( $transaction->{messages}->{resultCode} eq 'Ok' ) {

            #Awkward, but this is the way the response comes
            my $transaction_id = ( split ',', $transaction->{directResponse} )[6];
            $c->logger->info(
                sprintf(
                    'Customer id (%d) has succesfully paid for link_user_subscription(%d)',
                    $args->{link_user_subscription}->user_id,
                    $args->{link_user_subscription}->id
                )
            );
            try {
                $c->model('Chargemonk::Invoice')->create(
                    {   invoice_id                => $transaction_id,
                        user_id                   => $args->{link_user_subscription}->user_id,
                        link_user_subscription_id => $args->{link_user_subscription}->id,
                        gateway                   => "authorize.net",
                        charge                    => $amount
                    }
                );
            }
            catch {
                $c->logger->error(
                    sprintf(
                        'Unable to save invoice (%s) for client(%d) to the <Invoice> table : %s',
                        $transaction_id, $args->{link_user_subscription}->user_id, $_
                    )
                );
            };

            $args->{link_user_subscription}->update( {'active' => 1} );
            
            return 1;
        }
        else {
            $c->logger->error(
                sprintf(
                    "Payment failed for customer(%d) : %s",
                    $args->{link_user_subscription}->user_id,
                    $transaction->{messages}->{message}->{text}
                )
            );
            $c->alert( {'error' => 'Payment failed:' . $transaction->{messages}->{message}->{text}} );
            try {
                $c->model('Chargemonk::Transaction')->create(
                    {   user_id                   => $args->{link_user_subscription}->user_id,
                        link_user_subscription_id => $args->{link_user_subscription}->id,
                        gateway                   => "authorize.net",
                        amount                    => $amount,
                        action                    => 'save_payment',
                        response_text             => $transaction->{messages}->{message}->{text}
                    }
                );
            }
            catch {
                $c->logger->error(
                    sprintf(
                        "Unable to save failed transaction for client(%d) to the Transaction table : %s",
                        $args->{link_user_subscription}->user_id, $_
                    )
                );
                return;
            } or return;
    
            return 0;
        }
    }
}

__PACKAGE__->meta->make_immutable;

1;
