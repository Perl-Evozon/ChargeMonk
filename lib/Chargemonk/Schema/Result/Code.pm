package Chargemonk::Schema::Result::Code;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->table("code");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "code_id_seq",
    },
    campaign_id => {data_type => "integer", is_foreign_key => 1, is_nullable => 0},
    code        => {data_type => "varchar", is_nullable    => 1, size        => 30},
    user_id     => {data_type => "integer", is_foreign_key => 1, is_nullable => 1},
    redeem_date => {data_type => "date",    is_nullable    => 1},
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
    "campaign",
    "Chargemonk::Schema::Result::Campaign",
    {"foreign.id" => "self.campaign_id"},
    {   is_deferrable => 1,
        join_type     => "LEFT",
        on_delete     => "CASCADE",
        on_update     => "CASCADE",
    },
);

__PACKAGE__->belongs_to(
    "user",
    "Chargemonk::Schema::Result::User",
    {id            => "user_id"},
    {is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE"},
);

__PACKAGE__->meta->make_immutable;

1;
