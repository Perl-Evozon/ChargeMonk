package SubMan::Schema::Result::SubscriptionDowngradeTo;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("subscription_downgrades_to");

__PACKAGE__->add_columns(
    subscription_id => { data_type => "integer", is_nullable => 0 },
    subscription_downgrade_id =>
      { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

__PACKAGE__->set_primary_key("subscription_id", "subscription_downgrade_id");

__PACKAGE__->belongs_to(
    "subscription_downgrade",
    "SubMan::Schema::Result::Subscription",
    { id            => "subscription_downgrade_id" },
    { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->meta->make_immutable;

1;
