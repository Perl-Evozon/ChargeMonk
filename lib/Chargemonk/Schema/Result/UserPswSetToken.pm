package Chargemonk::Schema::Result::UserPswSetToken;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("user_psw_set_token");

__PACKAGE__->add_columns(
  uid =>
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  token =>
  { data_type => "varchar", is_nullable => 0, size => 20 },
  created =>
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

__PACKAGE__->set_primary_key("uid");

__PACKAGE__->add_unique_constraint("user_psw_set_token_token_key", ["token"]);

__PACKAGE__->belongs_to(
  "uid",
  "Chargemonk::Schema::Result::User",
  { id => "uid" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

__PACKAGE__->meta->make_immutable;

1;
