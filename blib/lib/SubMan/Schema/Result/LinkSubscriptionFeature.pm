package SubMan::Schema::Result::LinkSubscriptionFeature;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("link_subscription_feature");

__PACKAGE__->add_columns(
    subscription_id =>
      { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
    feature_id =>
      { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

__PACKAGE__->set_primary_key("subscription_id", "feature_id");

__PACKAGE__->belongs_to(
    "feature",
    "SubMan::Schema::Result::Feature",
    { id            => "feature_id" },
    { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->belongs_to(
    "subscription",
    "SubMan::Schema::Result::Subscription",
    { id            => "subscription_id" },
    { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->meta->make_immutable;

1;
