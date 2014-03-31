package Chargemonk::Test::Register;

use Moose;
use DateTime;

use YAML::Tiny;
use Business::Stripe;

=head1 NAME

Chargemonk::Test::Register

=head1 DESCRIPTION

Registration testing module.

=head1 METHODS
=cut

has mech => (
    is       => 'ro',
    isa      => 'Chargemonk::Test::Mechanize',
    required => 1
);

has run_registration => (
    is      => 'rw',
    builder => 'run_tests',
    lazy    => 1
);

has subscription => (
    is  => 'ro',
    isa => 'Str'
);

has gateway => (
    is  => 'ro',
    isa => 'Str'
);

has run_gateway => (
    is      => 'rw',
    builder => 'register_with_gateway',
    lazy    => 1
);

=head2 run_tests

    Builder routine for the run method.
    Responsible for building the registration tests
    
=cut

sub run_tests {
    my $self = shift;

    foreach my $payment_scenario ( 'success', 'fail' ) {
        $self->register_payment( 'braintree', $payment_scenario );
        $self->register_payment( 'stripe',    $payment_scenario );
        $self->register_payment( 'authorize', $payment_scenario );
    }
}

sub register_payment {
    my ( $self, $payment_type, $payment_scenario ) = @_;

    my $test_subscription_data = {
        name                    => '___test_register_subscription',
        subscription_type       => 'regular',
        subscription_group_id   => 1,
        is_visible              => 0,
        require_company_data    => 0,
        has_auto_renew          => 1,
        access_type             => 'period',
        period                  => 2,
        period_unit             => 'Day',
        price                   => 10,
        currency                => 'EUR',
        number_of_users         => undef,
        min_active_period_users => undef,
        max_active_period_users => undef,
        call_to_action          => 'Subscribe!',
        has_trial               => 0,
        require_credit_card     => 1,
        position_in_group       => 1
    };

    my $test_trial_subscription_data = {
        name                    => '___test_register_trial_subscription',
        subscription_type       => 'regular',
        subscription_group_id   => 1,
        is_visible              => 0,
        require_company_data    => 0,
        has_auto_renew          => 1,
        access_type             => 'period',
        period                  => 2,
        period_unit             => 'Day',
        price                   => 10,
        currency                => 'EUR',
        number_of_users         => undef,
        min_active_period_users => undef,
        max_active_period_users => undef,
        call_to_action          => 'Subscribe!',
        trial_period            => 10,
        trial_price             => 0,
        trial_currency          => 'EUR',
        has_trial               => 1,
        require_credit_card     => 1,
        position_in_group       => 1
    };

#$self->mech->post_ok( "/admin/subscriptions/add_subscription", $test_subscription_data, 'Add normal subscription' );
#$self->mech->post_ok( "/admin/subscriptions/add_subscription", $test_trial_subscription_data, 'Add trial subscription' );
#
    my @subscription_type = ( 'subscription', 'trial' );

    foreach my $type (@subscription_type) {
        my $subscription =
            ( $type eq 'trial' )
            ? $self->mech->_app->model('Chargemonk::Subscription')->create($test_trial_subscription_data)
            : $self->mech->_app->model('Chargemonk::Subscription')->create($test_subscription_data);

#? $self->mech->_app->model('Chargemonk::Subscription')->search( { name => $test_trial_subscription_data->{name} } )->first()
#: $self->mech->_app->model('Chargemonk::Subscription')->search( { name => $test_subscription_data->{name} } )->first();

        if ( !$subscription ) {
            warn "No subscription with type:'$type' found";
            next;
        }

        $self->mech->get_ok( "/register/step-1/$type/" . $subscription->id );

=cut
    Get only columns which are required
=cut

        my $required_data = $self->mech->_app->model('Chargemonk::Registration')->find( {id => 1} );
        my @cols = (
            'first_name',      'last_name',     'address',          'address_2',
            'country',         'date_of_birth', 'state',            'zip_code',
            'phone_number',    'sex',           'company_name',     'company_address',
            'company_country', 'company_state', 'company_zip_code', 'company_phone_number'
        );
        @cols = grep { defined $required_data->$_ and $required_data->$_ } @cols;
        my $moniker_map = {
            date_of_birth        => 'birthday',
            first_name           => 'firstname',
            last_name            => 'lastname',
            address_2            => 'address2',
            phone_number         => 'phone',
            sex                  => 'gender',
            company_phone_number => 'company_phone'
        };
        my %required_user_cols = map { $moniker_map->{$_} ? ( $moniker_map->{$_} => 'test' ) : ( $_ => 'test' ) } @cols;

        $required_user_cols{email}    = 'new_user@email.com';
        $required_user_cols{password} = 'pass';
        $required_user_cols{gender}   = 'M' if ( $required_user_cols{gender} );
        $required_user_cols{user_type}= 'LEAD';
        $required_user_cols{terms}    = 'on';

        my $days_to_add = ( $type eq 'trial' ) ? $subscription->trial_period : $subscription->period;
        $required_user_cols{active_from_date} = DateTime->now()->strftime("%Y-%m-%d");
        $required_user_cols{active_to_date} = DateTime->now()->add( days => $days_to_add )->strftime("%Y-%m-%d");

        my $existing_user_data = {
            gender    => 'M',
            firstname => 'John',
            lastname  => 'P',
            email     => 'johnp@email.com',
            birthday  => 'April 15, 1971',
            address   => 'test address',
            address2  => 'test address 2',
            country   => 'Romania',
            password  => 'pass',
            user_type => 'LEAD'
        };

        my $existing_user          = $self->mech->_app->model('Chargemonk::User')->create($existing_user_data);
        my $existing_user_scenario = {
            post => {
                email    => $existing_user_data->{email},
                password => 'pass',
                terms    => 'on'
            },
            message => 'Email already exists'
        };
        $self->mech->post_ok(
            "/register/step-1-confirmation/$type/" . $subscription->id,
            $existing_user_scenario->{post},
            $existing_user_scenario->{message}
        );
        $self->mech->content_contains( $existing_user_scenario->{message} );
        $existing_user->delete();

        my $residual_user =
            $self->mech->_app->model('Chargemonk::User')->search( {email => $required_user_cols{email}} )->first();
        $residual_user->delete() if ($residual_user);

=cut
    Remove gradually field values
    and test user registration
=cut

        my %test_required_data = %required_user_cols;
        foreach my $user_data ( keys %test_required_data ) {
            next if ( grep { $user_data eq $_ } qw ( active_to_date active_from_date type ) );
            $test_required_data{$user_data} = '';
            $self->mech->post_ok( "/register/step-1-confirmation/$type/" . $subscription->id,
                \%test_required_data, "no $user_data" );
            $self->mech->content_contains('can not be empty');
        }

        $self->mech->post_ok( "/register/step-1-confirmation/$type/" . $subscription->id,
            \%required_user_cols, 'Add new user' );
        $self->mech->content_contains('Please verify your email address');

        my $new_user =
            $self->mech->_app->model('Chargemonk::User')->search( {email => $required_user_cols{email}} )->first();

        $self->mech->get_ok( '/activate_email?token=' . $new_user->user_registration_token->token );

        my $credentials = {
            authorize => {
                name               => 'Test Name',
                number             => '4111111111111111',
                cvv                => '111',
                month              => '07',
                year               => '2016',
                registration_token => $new_user->user_registration_token->token
            },
            braintree => {
                name               => 'Test Name',
                number             => '4111111111111111',
                cvv                => '111',
                month              => 7,
                year               => 2016,
                registration_token => $new_user->user_registration_token->token
            },
            stripe => {
                stripeToken        => $self->_get_stripe_token(),
                registration_token => $new_user->user_registration_token->token
            }
        };

        my $gateway_config   = YAML::Tiny->read('conf/gateway.yaml');
        my $original_gateway = $gateway_config->[0]->{'default'};
        $gateway_config->[0]->{'default'} = $payment_type;
        $gateway_config->write('conf/gateway.yaml');

        my $fail_value = ( grep { $_ ne 'registration_token' } keys %{$credentials->{$payment_type}} )[0];
        $credentials->{$payment_type}->{$fail_value} = '' if ( $payment_scenario eq 'fail' );

        $self->mech->get_ok(
            "/register/step-2/$type/" . $subscription->id . "/?token=" . $new_user->user_registration_token->token );
        $self->mech->post_ok(
            "/register/step-3/$type/" . $subscription->id . "/?token=" . $new_user->user_registration_token->token,
            $credentials->{$payment_type},
            "Start payment with $payment_type"
        );
        $self->mech->content_contains('Credit Card Info');
        $self->mech->post_ok(
            "/register/complete_registration",
            {registration_token => $new_user->user_registration_token->token},
            "$type registration. Payment with $payment_type in $payment_scenario case"
        );

        if ( $payment_scenario eq 'success' ) {
            $self->mech->content_contains('Success!');
        }
        else {
            $self->mech->content_contains('Error!');
        }

        $gateway_config->[0]->{default} = $original_gateway;
        $gateway_config->write('conf/gateway.yaml');

        $new_user->delete();
        $subscription->delete();

    }
}

=head2 register_with_gateway

    Register using a specific gateway

=cut

sub register_with_gateway {
    my $self            = shift;
    my $payment_type    = $self->gateway;
    my $subscription_id = $self->subscription;

    my $subscription = $self->mech->_app->model('Chargemonk::Subscription')->search( {id => $subscription_id} )->first();


    $self->mech->get_ok( "/register/step-1/subscription/" . $subscription_id );

=cut
    Get only columns which are required
=cut

    my $required_data = $self->mech->_app->model('Chargemonk::Registration')->find( {id => 1} );
    my @cols = (
        'first_name',      'last_name',     'address',          'address_2',
        'country',         'date_of_birth', 'state',            'zip_code',
        'phone_number',    'sex',           'company_name',     'company_address',
        'company_country', 'company_state', 'company_zip_code', 'company_phone_number'
    );
    @cols = grep { defined $required_data->$_ and $required_data->$_ } @cols;
    my $moniker_map = {
        date_of_birth        => 'birthday',
        first_name           => 'firstname',
        last_name            => 'lastname',
        address_2            => 'address2',
        phone_number         => 'phone',
        sex                  => 'gender',
        company_phone_number => 'company_phone'
    };
    my %required_user_cols = map { $moniker_map->{$_} ? ( $moniker_map->{$_} => 'test' ) : ( $_ => 'test' ) } @cols;

    $required_user_cols{email}    = '___test_email_new_user@email.com';
    $required_user_cols{password} = 'pass';
    $required_user_cols{gender}   = 'M' if ( $required_user_cols{gender} );
    $required_user_cols{user_type}= 'LEAD';
    $required_user_cols{terms}    = 'on';

    $required_user_cols{active_from_date} = DateTime->now()->strftime("%Y-%m-%d");
    $required_user_cols{active_to_date} = DateTime->now()->add( days => $subscription->period )->strftime("%Y-%m-%d");

    $self->mech->post_ok( "/register/step-1-confirmation/subscription/" . $subscription->id,
        \%required_user_cols, 'Add new user' );
    $self->mech->content_contains('Please verify your email address');

    my $new_user =
        $self->mech->_app->model('Chargemonk::User')->search( {email => $required_user_cols{email}} )->first();

    $self->mech->get_ok( '/activate_email?token=' . $new_user->user_registration_token->token );

    my $credentials = {
        authorize => {
            name               => 'Test Name',
            number             => '4111111111111111',
            cvv                => '111',
            month              => '07',
            year               => '2016',
            registration_token => $new_user->user_registration_token->token
        },
        braintree => {
            name               => 'Test Name',
            number             => '4111111111111111',
            cvv                => '111',
            month              => 7,
            year               => 2016,
            registration_token => $new_user->user_registration_token->token
        },
        stripe => {
            stripeToken        => $self->_get_stripe_token(),
            registration_token => $new_user->user_registration_token->token
        }
    };

    my $gateway_config   = YAML::Tiny->read('conf/gateway.yaml');
    my $original_gateway = $gateway_config->[0]->{'default'};
    $gateway_config->[0]->{'default'} = $payment_type;
    $gateway_config->write('conf/gateway.yaml');


    $self->mech->get_ok(
        "/register/step-2/subscription/" . $subscription->id . "/?token=" . $new_user->user_registration_token->token );
    $self->mech->post_ok(
        "/register/step-3/subscription/" . $subscription->id . "/?token=" . $new_user->user_registration_token->token,
        $credentials->{$payment_type},
        "Start payment with $payment_type"
    );
    $self->mech->content_contains('Credit Card Info');
    $self->mech->post_ok(
        "/register/complete_registration",
        {registration_token => $new_user->user_registration_token->token},
        "Payment with $payment_type card"
    );

    $self->mech->content_contains('Success!');

    $gateway_config->[0]->{default} = $original_gateway;
    $gateway_config->write('conf/gateway.yaml');

    return $new_user;

}


sub _get_stripe_token {
    my $self = shift;

    my $stripe_params = {
        number    => 4242424242424242,
        exp_month => 07,
        exp_year  => 2014,
        cvc       => 123,
        currency  => 'usd'
    };

    my $stripe = Business::Stripe->new( -api_key => 'sk_test_hW9r8WSQME6YudrD8HzMbOCY' );
    $stripe->api(
        'post', 'tokens',
        'card[number]'    => $stripe_params->{number},
        'card[exp_month]' => $stripe_params->{exp_month},
        'card[exp_year]'  => $stripe_params->{exp_year},
        'card[cvc]'       => $stripe_params->{cvc},
        'currency'        => $stripe_params->{currency}
    );

    return $stripe->success->{id} if ( $stripe->success );

    return '';
}

1;
