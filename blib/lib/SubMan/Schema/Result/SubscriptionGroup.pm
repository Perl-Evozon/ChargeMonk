package SubMan::Schema::Result::SubscriptionGroup;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("subscription_group");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "subscription_group_id_seq",
    },
    name          => { data_type => "varchar", is_nullable => 0, size => 40 },
    creation_date => {
        data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
        original      => { default_value => \"now()" },
    },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint( "unique_names", ["name"] );

__PACKAGE__->has_many(
    "subscriptions",
    "SubMan::Schema::Result::Subscription",
    { "foreign.subscription_group_id" => "self.id" },
    { cascade_copy                    => 0, cascade_delete => 0 },
);

__PACKAGE__->meta->make_immutable;

1;
