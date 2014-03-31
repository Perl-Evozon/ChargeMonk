package Chargemonk::Controller::API::Register;

use Moose;
use namespace::autoclean;
use DateTime;

BEGIN { extends 'Chargemonk::Controller::Authenticated' }

=head1 NAME

Chargemonk::Controller::Payment

=head1 METHODS

=head2 index
=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    #Cross domain access
    $c->response->headers->header( 'Access-Control-Allow-Origin' => '*' );

    return 1;
}

=head2 pricing

Pricing and Sign-Up page (/pricing)

=cut

sub index : Path(/api/register) : Public {
    my ( $self, $c ) = @_;

    my $subscription = $c->model('Chargemonk::Subscription')->find( {id => $c->req->params->{sid}} );
    my @features = $c->model('Chargemonk::LinkSubscriptionFeature')->search( {subscription_id => $subscription->id} )->all;
    my $required_data =
        $c->model('Chargemonk::Registration')->find( {id => 1} );

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
        {   template              => 'api/register.tt',
            subscription          => $subscription,
            features              => \@features,
            trial                 => $c->req->params->{trial} ? 1 : 0,
            required_data         => $required_data,
            required_company_info => $required_company_info,
            has_campaigns         => scalar(@running_campaigns) ? 1 : 0,
            success_page_return   => $c->req->params->{success_page_return},
            email_page_return     => $c->req->params->{email_page_return}
        }
    );

}

__PACKAGE__->meta->make_immutable;

1;
