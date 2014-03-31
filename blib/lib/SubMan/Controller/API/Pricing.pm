package SubMan::Controller::API::Pricing;

use Moose;
use namespace::autoclean;
use DateTime;

BEGIN { extends 'SubMan::Controller::Authenticated' }

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

=head2 pricing

Pricing and Sign-Up page (/pricing)

=cut

sub index : Path(/api/pricing) : Public {
    my ( $self, $c ) = @_;

    my @groups;
    foreach my $group ( $c->model('SubMan::SubscriptionGroup')->search( {}, {order_by => 'id'} )->all ) {

        my @subscriptions;
        foreach my $subscription (
            $c->model('SubMan::Subscription')->search_rs( {subscription_group_id => $group->id}, {order_by => 'id'} )
            ->all )
        {

            my @features =
                $c->model('SubMan::LinkSubscriptionFeature')->search( {subscription_id => $subscription->id} )->all;

            push(
                @subscriptions,
                {   rs       => $subscription,
                    features => \@features,
                }
            );
        }
        push(
            @groups,
            {   rs            => $group,
                subscriptions => \@subscriptions,
            }
        );
    }

    my $required_data =
        $c->model('SubMan::Registration')->find( {id => 1} );

    my @company_cols = (
        'company_name',     'company_address', 'company_country', 'company_state',
        'company_zip_code', 'company_phone_number'
    );

    my $required_company_info = grep { defined $required_data->$_ and $required_data->$_ } @company_cols;
   
    $c->stash(
        groups                => \@groups,
        required_data         => $required_data,
        required_company_info => $required_company_info,
        template              => 'api/pricing.tt',
        register_page_return  => $c->req->params->{register_page_return}
    );

}

__PACKAGE__->meta->make_immutable;

1;
