package Chargemonk::Schema::Result::Feature;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("feature");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "feature_id_seq",
    },
    name        => { data_type => "varchar", is_nullable => 0, size => 30 },
    description => { data_type => "varchar", is_nullable => 1, size => 200 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint( "unique_feature_names", ["name"] );

__PACKAGE__->has_many(
    "link_subscription_feature",
    "Chargemonk::Schema::Result::LinkSubscriptionFeature",
    { "foreign.feature_id" => "self.id" },
    { cascade_copy         => 0, cascade_delete => 0 },
);

__PACKAGE__->meta->make_immutable;

1;
