package Chargemonk::Schema::Result::Subscription;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("subscription");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "subscription_id_seq",
    },
    name => { data_type => "varchar", is_nullable => 1, size => 40 },
    subscription_type => {
        data_type => "enum",
        extra     => {
            custom_type_name => "subscription_type",
            list             => [ "regular", "promo" ],
        },
        is_nullable => 1,
    },
    subscription_group_id =>
      { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
    is_visible =>
      { data_type => "boolean", default_value => \"false", is_nullable => 0 },
    require_company_data =>
      { data_type => "boolean", default_value => \"false", is_nullable => 0 },
    has_auto_renew =>
      { data_type => "boolean", default_value => \"false", is_nullable => 0 },
    access_type => {
        data_type => "enum",
        extra     => {
            custom_type_name => "subscription_access_type",
            list             => [
                "period", "period_users", "IP_range", "resources",
                "API_calls"
            ],
        },
        is_nullable => 1,
    },
    period => { data_type => "integer", is_nullable => 1 },
    price  => { data_type => "integer", is_nullable => 1 },
    call_to_action =>
      { data_type => "varchar", is_nullable => 1, size => 30 },
    has_trial =>
      { data_type => "boolean", default_value => \"true", is_nullable => 1 },
    min_active_period_users => { data_type => "integer", is_nullable => 1 },
    max_active_period_users => { data_type => "integer", is_nullable => 1 },
    position_in_group       => { data_type => "integer", is_nullable => 0 },
    currency                => {
        data_type => "enum",
        extra     => {
            custom_type_name => "currency_type",
            list             => [
                "EUR",
                "USD",
                "GBP",
                "RON",
                "XAU",
                "AUD",
                "CAD",
                "CHF",
                "CZK",
                "DKK",
                "EGP",
                "HUF",
                "JPY",
                "MDL",
                "NOK",
                "PLN",
                "SEK",
                "TRY",
                "XDR",
                "RUB",
                "BGN",
                "ZAR",
                "BRL",
                "CNY",
                "INR",
                "KRW",
                "MXN",
                "NZD",
                "RSD",
                "UAH",
                "AED",
            ],
        },
        is_nullable => 1,
    },
    number_of_users => { data_type => "integer", is_nullable => 1 },
    trial_period    => { data_type => "integer", is_nullable => 1 },
    trial_price     => { data_type => "integer", is_nullable => 1 },
    trial_currency  => {
        data_type => "enum",
        extra     => {
            custom_type_name => "currency_type",
            list             => [
                "EUR",
                "USD",
                "GBP",
                "RON",
                "XAU",
                "AUD",
                "CAD",
                "CHF",
                "CZK",
                "DKK",
                "EGP",
                "HUF",
                "JPY",
                "MDL",
                "NOK",
                "PLN",
                "SEK",
                "TRY",
                "XDR",
                "RUB",
                "BGN",
                "ZAR",
                "BRL",
                "CNY",
                "INR",
                "KRW",
                "MXN",
                "NZD",
                "RSD",
                "UAH",
                "AED",
            ],
        },
        is_nullable => 1,
    },
    require_credit_card =>
      { data_type => "boolean", default_value => \"false", is_nullable => 1 },
    created => {
        data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
        original      => { default_value => \"now()" },
    },
    created_by    => { data_type => "varchar", is_nullable => 1, size => 80 },
    resource_type => {
        data_type     => "varchar",
        default_value => \"null",
        is_nullable   => 1,
        size          => 40,
    },
    min_resource_quantity => { data_type => "integer", is_nullable => 1 },
    max_resource_quantity => { data_type => "integer", is_nullable => 1 },
    min_active_ips        => { data_type => "integer", is_nullable => 1 },
    max_active_ips        => { data_type => "integer", is_nullable => 1 },
    api_calls_volume      => { data_type => "integer", is_nullable => 1 },
    period_count          => { data_type => "integer", is_nullable => 1 },
    period_unit           => {
        data_type => "enum",
        extra     => {
            custom_type_name => "subscription_period_type",
            list             => [ "Day", "Week", "Month", "Year" ],
        },
        is_nullable => 1,
    },
    trial_period_count => { data_type => "integer", is_nullable => 1 },
    trial_period_unit  => {
        data_type => "enum",
        extra     => {
            custom_type_name => "subscription_period_type",
            list             => [ "Day", "Week", "Month", "Year" ],
        },
        is_nullable => 1,
    },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->has_many(
    "link_subscription_feature",
    "Chargemonk::Schema::Result::LinkSubscriptionFeature",
    { "foreign.subscription_id" => "self.id" },
    { cascade_copy              => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
    "link_user_subscription",
    "Chargemonk::Schema::Result::LinkUserSubscription",
    { "foreign.subscription_id" => "self.id" },
    { cascade_copy              => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
    "period_users",
    "Chargemonk::Schema::Result::PeriodUser",
    { "foreign.subscription_id" => "self.id" },
    { cascade_copy              => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
    "subscription_downgrades_to",
    "Chargemonk::Schema::Result::SubscriptionDowngradeTo",
    { "foreign.subscription_downgrade_id" => "self.id" },
    { cascade_copy                        => 0, cascade_delete => 0 },
);

__PACKAGE__->belongs_to(
    "subscription_group",
    "Chargemonk::Schema::Result::SubscriptionGroup",
    { id => "subscription_group_id" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "CASCADE",
        on_update     => "CASCADE",
    },
);

__PACKAGE__->has_many(
    "subscription_upgrades_to",
    "Chargemonk::Schema::Result::SubscriptionUpgradeTo",
    { "foreign.subscription_upgrade_id" => "self.id" },
    { cascade_copy                      => 0, cascade_delete => 0 },
);

__PACKAGE__->has_many(
    "campaigns",
    "Chargemonk::Schema::Result::Campaign",
    { "foreign.subscription_id" => "self.id" },
    { cascade_copy              => 0, cascade_delete => 0 },
);


=head 2

delete

Delete relations before deleting the record itself otherwise it'll crash because of the db onstraint
The dbix cascade_delete is trying to delete the related after deleting the record itself, looks to be a dbix bug

=cut

sub delete {
    my ( $self, @args ) = @_;

    $self->delete_related('subscription_downgrades_to');
    $self->delete_related('subscription_upgrades_to');

    $self->next::method(@args);
}

__PACKAGE__->meta->make_immutable;

1;
