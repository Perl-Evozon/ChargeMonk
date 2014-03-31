package SubMan::Controller::Admin::Stats;

use DateTime;
use Moose;
use namespace::autoclean;

BEGIN { extends 'SubMan::Controller::Authenticated'; }

has 'from' => ( is => 'rw', isa => 'DateTime', default => sub { DateTime->now()->subtract( days => 7 ) } );
has 'to'   => ( is => 'rw', isa => 'DateTime', default => sub { DateTime->now() } );
has 'unit' => ( is => 'rw', isa => 'Str',      default => 'days' );
has 'frequency'      => ( is => 'rw', isa => 'Num', default => 1 );
has 'frequency_unit' => ( is => 'rw', isa => 'Str', default => 'days' );

with 'SubMan::Helpers::Stats::Subscribers';

=head1 NAME

SubMan::Controller::Admin::Stats - Catalyst Controller

=head1 DESCRIPTION

Stats controller

=head1 METHODS

=cut

=head2 auto
=cut

sub auto : Private {
    my ( $self, $c ) = @_;
    my $params = $c->req->params;

    my $period_data = {
        '1w' => {
            value_to_subtract => 7,
            subtract_unit     => 'days',
            frequency         => 1,
            frequency_unit    => 'days'
        },
        '2w' => {
            value_to_subtract => 14,
            subtract_unit     => 'days',
            frequency         => 2,
            frequency_unit    => 'days'
        },
        '1m' => {
            value_to_subtract => 1,
            subtract_unit     => 'months',
            frequency         => 1,
            frequency_unit    => 'weeks'

        },
        '3m' => {
            value_to_subtract => 3,
            subtract_unit     => 'months',
            frequency         => 1,
            frequency_unit    => 'months'
        },
        '6m' => {
            value_to_subtract => 6,
            subtract_unit     => 'months',
            frequency         => 1,
            frequency_unit    => 'months'
        },
        '1y' => {
            value_to_subtract => 12,
            subtract_unit     => 'months',
            frequency         => 1,
            frequency_unit    => 'months'
        }
    };

    $self->from(
        DateTime->now()->subtract(
            $period_data->{$params->{period}}->{subtract_unit} => $period_data->{$params->{period}}->{value_to_subtract}
        )
    );
    $self->unit( $period_data->{$params->{period}}->{subtract_unit} );
    $self->frequency( $period_data->{$params->{period}}->{frequency} );
    $self->frequency_unit( $period_data->{$params->{period}}->{frequency_unit} );

    return 1;
}

=head2 all

Set all the stats data on the response

=cut

sub all : Local : JSON {
    my ( $self, $c ) = @_;

    $c->forward('subscribers');
    $c->forward('revenue');
}


=head2 revenue

Set the revenue stats on the response

=cut

sub revenue : Local : JSON {
    my ( $self, $c ) = @_;
    
    $c->stash->{stats} = revenue_stats( $c, $self->from(), $self->to(), $self->unit(), $self->frequency(), $self->frequency_unit() );
}

=head2 revenue_prospect

Set the revenue_prospect stats on the response

=cut

sub revenue_prospect : Local : JSON {
    my ( $self, $c ) = @_;
    
    $c->stash->{stats} = revenue_prospect_stats( $c );
}

=head2 subscribers

Set the subscribers stats on the response

=cut

sub subscribers : Local : JSON {
    my ( $self, $c ) = @_;
   
    $c->stash->{stats} = subscribers_stats( $c, $self->from(), $self->to(), $self->unit(), $self->frequency(), $self->frequency_unit() );
}

=head2 subscriptions

Set the subscriptions stats on the response

=cut

sub subscriptions : Local : JSON {
    my ( $self, $c ) = @_;
    
    $c->stash->{stats} = subscription_stats( $c );
}

=head1 AUTHOR

MeSe

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
