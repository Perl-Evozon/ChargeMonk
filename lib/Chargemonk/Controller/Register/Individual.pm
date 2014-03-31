package Chargemonk::Controller::Register::Individual;

use Moose;
use namespace::autoclean;
use Try::Tiny;

use Chargemonk::Helpers::Visitor::Registration;

BEGIN { extends 'Chargemonk::Controller::Authenticated'; }

=head1 NAME

Chargemonk::Controller::Register::Individual - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 register

Subscription registration page

=cut

sub step_1 : Path('/register/individual/step-1') : Args(2) {
    my ( $self, $c ) = @_;

    my $subscription = $c->model('Chargemonk::Subscription')->find( {id => $c->request->arguments->[1]} );
    my @features = $c->model('Chargemonk::LinkSubscriptionFeature')->search( {subscription_id => $subscription->id} )->all;
    my $required_data =
        $c->model('Chargemonk::Registration')->find( {id => 1} );

    $c->stash(
        {   template      => 'register/individual/step-1.tt',
            subscription  => $subscription,
            features      => \@features,
            trial         => $c->request->arguments->[0] eq 'trial' ? 1 : 0,
            required_data => $required_data,
        }
    );
}

=head2 validation_rules

    Validation rules for details submission
    
=cut

__PACKAGE__->validation_rules(
    step_1_confirmation => {
        password => [NotEmpty => 'Email/Password fields can not be empty'],
        email    => [
            NotEmpty   => 'Email/Password fields can not be empty',
            UniqueUser => 'Email already exists'
        ],
        terms => [NotEmpty => 'Please agree with terms and conditions'],
    }
);

sub step_1_confirmation : Path('/register/individual/step-1-confirmation') : Args(2) : OnError(step_1) {
    my ( $self, $c ) = @_;

    $c->response->redirect('/pricing') unless $c->req->param;

    my $subscription = $c->model('Chargemonk::Subscription')->find( {id => $c->request->arguments->[1]} );
    my @features = $c->model('Chargemonk::LinkSubscriptionFeature')->search( {subscription_id => $subscription->id} )->all;

    my @cols = qw(
        email password firstname lastname address address2 country state zip_code phone gender
        company_name company_address company_country company_zip_code company_phone
    );

    my $user_hash;
    map { $user_hash->{$_} = $c->req->param($_) || undef } @cols;
    $user_hash->{user_type} = 'LEAD';

    my $user_rs;
    try {
        $user_rs = $c->model('Chargemonk::User')->create($user_hash);
    }
    catch {
        $c->stash->{errors} =
            {message => ['Details were already submited. Please check your email to complete registration']};
        $c->go("step_1");
    };

    my $link_user_subscription = $c->model('Chargemonk::LinkUserSubscription')->create(
        {   user_id            => $user_rs->id,
            subscription_id    => $subscription->id,
            nr_of_period_users => $c->req->param('nr_of_period_users') || 1,
            active_from_date   => $c->req->param('active_from_date'),
            active_to_date     => $c->req->param('active_to_date'),
        }
    );

    Chargemonk::Helpers::Visitor::Registration::send_register_user_email(
        {   c                         => $c,
            user_id                   => $user_rs->id,
            link_user_subscription_id => $link_user_subscription->id,
            email                     => $c->req->param('email'),
            flow_type                 => 'individual',
        }
    );

    $c->stash(
        {   template     => 'register/individual/step-1-confirmation.tt',
            subscription => $subscription,
            features     => \@features,
            trial        => $c->request->arguments->[0] eq 'trial' ? 1 : 0,
        }
    );

    return;
}

sub step_2 : Path('/register/individual/step-2') : Args(2) {
    my ( $self, $c ) = @_;

    $c->response->redirect('/pricing') unless $c->req->param('token');

    my $active_gateway      = Chargemonk::Helpers::Gateways::Details::get_active_gateway;
    my $template            = 'register/individual/step-2-' . $active_gateway . '.tt';
    my $gateway_credentials = Chargemonk::Helpers::Gateways::Details::get_gateway_credentials( $c, $active_gateway );

    $c->stash(
        {   template    => $template,
            credentials => $gateway_credentials,
        }
    );

    return;
}

sub step_3 : Path('/register/individual/step-3') : Args(2) {
    my ( $self, $c ) = @_;

    $c->response->redirect('/pricing') unless $c->req->param;
    $c->session->{'cc'} = $c->req->params;

    my $subscription = $c->model('Chargemonk::Subscription')->find( {id => $c->request->arguments->[1]} );
    $c->stash(
        {   template     => 'register/individual/step-3.tt',
            subscription => $subscription,
        }
    );

    return;
}

__PACKAGE__->meta->make_immutable;

1;
