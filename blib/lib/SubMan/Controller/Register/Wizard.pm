package SubMan::Controller::Register::Wizard;

use DateTime;
use Moose;
use namespace::autoclean;
use Try::Tiny;

use SubMan::Helpers::Visitor::Registration;

BEGIN { extends 'SubMan::Controller::Authenticated'; }

=head1 NAME

SubMan::Controller::Register::Wizard - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 register

Subscription registration page

=cut

sub step_1 : Path('/register/step-1') : Args(2) : Public {
    my ( $self, $c ) = @_;

    my $subscription = $c->model('SubMan::Subscription')->find( {id => $c->request->arguments->[1]} );
    my @features = $c->model('SubMan::LinkSubscriptionFeature')->search( {subscription_id => $subscription->id} )->all;
    my $required_data =
        $c->model('SubMan::Registration')->find( {id => 1} );

    my @company_cols = (
        'company_name',     'company_address', 'company_country', 'company_state',
        'company_zip_code', 'company_phone_number'
    );

    my $required_company_info = grep { defined $required_data->$_ and $required_data->$_ } @company_cols;

    my @running_campaigns = $subscription->search_related(
        'campaigns',
        {   start_date => {'<', DateTime->now()->ymd()},
            end_date   => {'>', DateTime->now()->ymd()},
        }
    );

    $c->stash(
        {   template              => 'register/wizard/step-1.tt',
            subscription          => $subscription,
            features              => \@features,
            trial                 => $c->req->args->[0] eq 'trial' ? 1 : 0,
            required_data         => $required_data,
            required_company_info => $required_company_info,
            has_campaigns         => scalar(@running_campaigns) ? 1 : 0,
        }
    );
}

=head2 validation_rules

    Validation rules for details submission
    
=cut

__PACKAGE__->validation_rules(
    step_1_confirmation => {
        password => [NotEmpty => 'Password field can not be empty'],
        email    => [
            NotEmpty   => 'Email field can not be empty',
            UniqueUser => 'Email already exists'
        ],
        firstname        => [NotEmptyIfExists => 'First Name field can not be empty'],
        lastname         => [NotEmptyIfExists => 'Last Name field can not be empty'],
        gender           => [NotEmptyIfExists => 'Please select gender'],
        address          => [NotEmptyIfExists => 'Address field can not be empty'],
        country          => [NotEmptyIfExists => 'Country field can not be empty'],
        state            => [NotEmptyIfExists => 'State field can not be empty'],
        zip_code         => [NotEmptyIfExists => 'Zip Code field can not be empty'],
        phone            => [NotEmptyIfExists => 'Phone field can not be empty'],
        birthday         => [NotEmptyIfExists => 'Date of Birth field can not be empty'],
        company_name     => [NotEmptyIfExists => 'Company Name field can not be empty'],
        company_address  => [NotEmptyIfExists => 'Company Address field can not be empty'],
        company_state    => [NotEmptyIfExists => 'Company State field can not be empty'],
        company_zip_code => [NotEmptyIfExists => 'Company Zip Code field can not be empty'],
        company_phone    => [NotEmptyIfExists => 'Company Phone field can not be empty'],
        discount_code    => [
            'Subscription::DiscountCodeExists'  => 'Discount code not found',
            'Subscription::DiscountCodeNotUsed' => 'Discount code already used',
        ],
    }
);

sub step_1_confirmation : Path('/register/step-1-confirmation') : Args(2) : OnError(step_1) : Public {
    my ( $self, $c ) = @_;

    $c->response->redirect('/pricing') unless $c->req->param;

    my $subscription = $c->model('SubMan::Subscription')->find( {id => $c->req->args->[1]} );
    my @features = $c->model('SubMan::LinkSubscriptionFeature')->search( {subscription_id => $subscription->id} )->all;

    my @cols = qw(
        email password firstname lastname address address2 country state zip_code phone gender
        company_name company_address company_country company_zip_code company_phone
    );

    my $user_hash;
    map { $user_hash->{$_} = $c->req->param($_) || undef } @cols;
    $user_hash->{user_type} = 'LEAD';

    my $user_rs;
    try {
        $user_rs = $c->model('SubMan::User')->create($user_hash);
    }
    catch {
        $c->stash->{errors} =
            {message => ['Details were already submited. Please check your email to complete registration']};
        $c->go("step_1");
    };

    # TODO: change the active_from_date and active_to_date to use the subscription params, not the ones from request
    my $link_user_subscription = $c->model('SubMan::LinkUserSubscription')->create(
        {   user_id            => $user_rs->id,
            subscription_id    => $subscription->id,
            nr_of_period_users => $c->req->param('nr_of_period_users') || 1,
            active_from_date   => $c->req->param('active_from_date'),
            active_to_date     => $c->req->param('active_to_date'),
        }
    );

    # mark the discount as used, if any code validated previously
    if ( my $dc = $c->req->param('discount_code') ) {
        my $code = $c->model('SubMan::Code')->search( {code => $dc} )->first();
        $code->update( {user_id => $user_rs->id, redeem_date => DateTime->now()} );
    }

    SubMan::Helpers::Visitor::Registration::send_register_user_email(
        {   c                         => $c,
            user_id                   => $user_rs->id,
            link_user_subscription_id => $link_user_subscription->id,
            email                     => $c->req->param('email'),
            flow_type                 => 'individual',
        }
    );

    $c->stash(
        {   template     => 'register/wizard/step-1-confirmation.tt',
            subscription => $subscription,
            features     => \@features,
            trial        => $c->req->args->[0] eq 'trial' ? 1 : 0,
        }
    );

    return;
}

sub step_2 : Path('/register/step-2') : Args(2) : Public {
    my ( $self, $c ) = @_;

    $c->response->redirect('/pricing') unless $c->req->param('token');

    my $active_gateway      = SubMan::Helpers::Gateways::Details::get_active_gateway;
    my $template            = 'register/wizard/step-2-' . $active_gateway . '.tt';
    my $gateway_credentials = SubMan::Helpers::Gateways::Details::get_gateway_credentials( $c, $active_gateway );

    $c->stash(
        {   template    => $template,
            credentials => $gateway_credentials,
        }
    );

    return;
}

sub step_3 : Path('/register/step-3') : Args(2) : Public {
    my ( $self, $c ) = @_;

    $c->response->redirect('/pricing') unless $c->req->param;
    $c->session->{'cc'} = $c->req->params;

    my $subscription = $c->model('SubMan::Subscription')->find( {id => $c->request->arguments->[1]} );
    $c->stash(
        {   template     => 'register/wizard/step-3.tt',
            subscription => $subscription,
        }
    );

    return;
}

__PACKAGE__->meta->make_immutable;

1;
