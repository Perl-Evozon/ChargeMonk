package Chargemonk::Schema::Result::LinkUserSubscription;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("link_user_subscription");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "link_user_subscription_id_seq",
    },
    user_id            => {data_type => "integer",   is_foreign_key => 1,        is_nullable => 0},
    subscription_id    => {data_type => "integer",   is_foreign_key => 1,        is_nullable => 0},
    nr_of_period_users => {data_type => "integer",   is_nullable    => 1},
    active_from_date   => {data_type => "datetime",  is_nullable    => 0},
    active_to_date     => {data_type => "datetime",  is_nullable    => 0},
    active             => {data_type => "boolean",   default_value  => \"false", is_nullable => 0},
    cancelled          => {data_type => "boolean",   default_value  => \"false", is_nullable => 0},
    process_date       => {data_type => "timestamp", is_nullable    => 1},
    process_message    => {data_type => "varchar",   is_nullable    => 1},
    process_status     => {data_type => "varchar",   is_nullable    => 1},
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
    "period_users",
    "Chargemonk::Schema::Result::PeriodUser",
    {"foreign.link_user_subscription_id" => "self.id"},
    {cascade_copy                        => 0, cascade_delete => 0},
);

__PACKAGE__->has_many(
    "ip_ranges",
    "Chargemonk::Schema::Result::IpRange",
    {"foreign.link_user_subscription_id" => "self.id"},
    {cascade_copy                        => 0, cascade_delete => 0},
);

__PACKAGE__->has_many(
    "invoices",
    "Chargemonk::Schema::Result::Invoice",
    {"foreign.link_user_subscription_id" => "self.id"},
    {cascade_copy                        => 0, cascade_delete => 0},
);

__PACKAGE__->belongs_to(
    "subscription",
    "Chargemonk::Schema::Result::Subscription",
    {id            => "subscription_id"},
    {is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE"},
);

__PACKAGE__->belongs_to(
    "user",
    "Chargemonk::Schema::Result::User",
    {id            => "user_id"},
    {is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE"},
);


sub amount_with_discount {
    my $self = shift;

    # find the discount code, if any valid
    my @running_campaigns =
        $self->subscription->search_related( 'campaigns', {valability => {'>', DateTime->now()->ymd()},} );
    my @campaign_ids = map { $_->id() } @running_campaigns;

    foreach my $campaign (@running_campaigns) {
        my $code = $campaign->search_related( 'codes', {user_id => $self->user_id()} )->first();
        if ($code) {
            my $amount = 0;
            if ( $campaign->discount_type() eq 'unit' ) {
                $amount = $self->subscription->price() - $campaign->discount_amount();
            }
            elsif ( $campaign->discount_type() eq 'percent' ) {
                $amount = $self->subscription->price()
                    - ( $campaign->discount_amount() / 100 * $self->subscription->price() );
            }
            return $amount < 0 ? 0 : $amount;
        }

    }

    return undef;
}

__PACKAGE__->meta->make_immutable;

1;
