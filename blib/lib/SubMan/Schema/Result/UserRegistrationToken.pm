package SubMan::Schema::Result::UserRegistrationToken;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("user_registration_token");

__PACKAGE__->add_columns(
  user_id =>
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  link_user_subscription_id =>
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  token =>
  { data_type => "varchar", is_nullable => 0, size => 20 },
  flow_type =>
  { data_type => "varchar", is_nullable => 0, size => 10 },
  created =>
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

__PACKAGE__->set_primary_key("user_id");

__PACKAGE__->add_unique_constraint("user_registration_token_token_key", ["token"]);

__PACKAGE__->belongs_to(
  "user",
  "SubMan::Schema::Result::User",
  { "foreign.id" => "self.user_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->belongs_to(
  "subscription",
  "SubMan::Schema::Result::LinkUserSubscription",
  { "foreign.id" => "self.link_user_subscription_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->meta->make_immutable;

1;
