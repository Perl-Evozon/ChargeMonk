package SubMan::Helpers::Gateways::Braintree;
use Net::Braintree;

use Moose;
use Try::Tiny;

=head1 NAME

SubMan::Helpers::Gateways::Braintree- Helpers for SubMan payment gateway implemented with braintree

=head1 DESCRIPTION

Subman helpers for admin actions available on 'User Details' page.

=head1 METHODS

=cut

=head2
    Arguments necessary to create the object:
        args => {
            c                          => $c
            gateway_credentials        => $gateway_credentials, #( SubMan::Helpers::Gateways::Details::get_gateway_credentials( $c, $gateway ) )
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
        $c->model('SubMan::LinkUserSubscription')->find( {id => $self->args->{link_user_subscription_id}} );
    $self->args->{user} = $c->model('SubMan::User')->find( {id => $self->args->{link_user_subscription}->user_id} );
    $self->args->{subscription} =
        $c->model('SubMan::Subscription')->find( {id => $self->args->{link_user_subscription}->subscription_id} );

    my $gateway_credentials = $self->args->{gateway_credentials};

    my $config = Net::Braintree->configuration;
    $config->environment("sandbox");
    $config->merchant_id( $gateway_credentials->{'merchant_id'} );
    $config->public_key( $gateway_credentials->{'public_key'} );
    $config->private_key( $gateway_credentials->{'private_key'} );
}

=head2
    _add_user_and_pay
    Builder method for the add_user_and_pay Moose component.
    Performs addition of new user to braintree sandbox and payment
    request from this user
=cut

sub _add_user_and_pay {
    my $self = shift;

    my $c = $self->args->{c};

    $self->_initialize_gateway();

    my $customer = $c->model('SubMan::BraintreeUser')->find( {user_id => $self->args->{user}->id} );
    $self->args->{card_token} = ($customer) ? $customer->card_token : $self->_add_customer_with_card();

    return unless $self->args->{card_token};

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

    my $customer = $c->model('SubMan::BraintreeUser')->find( {user_id => $self->args->{user}->id} );
    $self->args->{card_token} = $customer->card_token if ($customer);

    $self->_charge_card();
}

=head2
    _delete_user
    Builder method for the delete_user Moose component.
    Deletes user from braintree sandbox
=cut

sub _delete_user {
    my $self = shift;

    my $c = $self->args->{c};

    $self->_initialize_gateway();

    my $result = Net::Braintree::Customer->delete( $self->args->{user}->id );

    return $result->is_success;
}

=head2
    _add_customer_with_card
    Helper method to add new account to braintree sandbox
=cut

sub _add_customer_with_card {
    my $self = shift;

    my $args   = $self->args;
    my $c      = $args->{c};
    my $result = Net::Braintree::Customer->create(
        {   id          => $args->{user}->id,
            first_name  => $args->{user}->firstname,
            last_name   => $args->{user}->lastname,
            email       => $args->{user}->email,
            credit_card => {
                number           => $args->{credit_card}->{number},
                expiration_month => $args->{credit_card}->{month},
                expiration_year  => $args->{credit_card}->{year},
                cvv              => $args->{credit_card}->{cvv},
                cardholder_name  => $args->{credit_card}->{name},
                options          => {verify_card => 1}
            }
        }
    );

    if ( $result && $result->is_success ) {
        my $customer_id = $result->customer->id;
        my $card_token  = $result->customer->credit_cards->[0]->token;
        my $card_info   = $result->customer->credit_cards->[0];

        $c->logger->info("Customer id ($customer_id) was succesfully added to vault with credit card($card_token)");

        try {
            $c->model('SubMan::BraintreeUser')->create(
                {   card_token      => $card_token,
                    user_id         => $customer_id,
                    card_type       => $card_info->card_type,
                    last_four       => $card_info->last_4,
                    expiration_date => join( '-', $card_info->expiration_year, $card_info->expiration_month, '01' )
                }
            );
        }
        catch {
            $c->logger->error( sprintf( "Unable to save user (%d) <braintree_user> table: %s", $customer_id, $_ ) );
        };

        return $card_token;
    }
    else {
        try {
            $c->model('SubMan::Transaction')->create(
                {   user_id                   => $args->{user}->id,
                    link_user_subscription_id => $args->{link_user_subscription}->id,
                    gateway                   => "braintree",
                    amount                    => 0,
                    action                    => 'save_customer',
                    response_text             => $result->message
                }
            );
        }
        catch {
            $c->logger->error(
                sprintf(
                    "Unable to save failed customer(%d) creation to the Transaction table : %s",
                    $args->{user}->id, $_
                )
            );
        };

        $c->alert( {'error' => 'Payment failed:' . $result->message},
            sprintf( "Customer id (%d) failed to be added to the vault: %s", $args->{user}->id, $result->message ) );

        return;
    }

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
            $c->model('SubMan::Invoice')->create(
                {   invoice_id                => 0,
                    user_id                   => $args->{user}->id,
                    link_user_subscription_id => $args->{link_user_subscription}->id,
                    gateway                   => "braintree",
                    charge                    => 0,
                }
            );
        }
        catch {
            $c->logger->error(
                sprintf( 'Unable to save invoice for client(%d) to the <Invoice> table : %s', $args->{user}->id, $_ ) );
            return;
        } or return;

        $args->{link_user_subscription}->update( {'active' => '1'} );
    }

    my $result = Net::Braintree::Transaction->sale(
        {   amount               => $charge_ammount,
            payment_method_token => $args->{card_token},
            options              => {submit_for_settlement => 1}
        }
    );

    if ( $result && $result->is_success ) {
        $c->logger->info(
            sprintf(
                'Customer id (%d) has succesfully paid for link_user_subscription(%d) having
            the transaction_id(%s)', $args->{user}->id, $args->{link_user_subscription}->id,
                $result->transaction->id
            )
        );

        try {
            $c->model('SubMan::Invoice')->create(
                {   invoice_id                => $result->transaction->id,
                    user_id                   => $args->{link_user_subscription}->user_id,
                    link_user_subscription_id => $args->{link_user_subscription}->id,
                    gateway                   => "braintree",
                    charge                    => $charge_ammount,
                }
            );
        }
        catch {
            $c->logger->error(
                sprintf(
                    'Unable to save invoice (%s) for client(%d) to the <Invoice> table : %s',
                    $result->transaction->id,
                    $args->{user}->id, $_
                )
            );
        };

        $args->{link_user_subscription}->update( {'active' => 1} );
        
        return 1;
    }
    else {
        $c->alert({error => 'Payment failed:' . $result->message}, sprintf( "Payment failed for customer(%d): %s", $args->{user}->id, $result->message ));

        try {
            $c->model('SubMan::Transaction')->create(
                {   user_id                   => $args->{link_user_subscription}->user_id,
                    link_user_subscription_id => $args->{link_user_subscription}->id,
                    gateway                   => "braintree",
                    amount                    => $charge_ammount,
                    action                    => 'save_payment',
                    response_text             => $result->message
                }
            );
        }
        catch {
            $c->logger->error(
                sprintf(
                    "Unable to save failed transaction for client(%d) to the Transaction table : %s",
                    $args->{user}->id, $_
                )
            );
        };

        return;
    }
}

__PACKAGE__->meta->make_immutable;

1;
