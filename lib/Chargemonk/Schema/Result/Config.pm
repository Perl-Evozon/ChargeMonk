package Chargemonk::Schema::Result::Config;

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
use utf8;

extends 'DBIx::Class::Core';

__PACKAGE__->table("config");

__PACKAGE__->add_columns(
    key   => {data_type => "varchar", is_nullable => 0},
    value => {data_type => "varchar", is_nullable => 0}
);

__PACKAGE__->set_primary_key("key");

__PACKAGE__->meta->make_immutable;

1;
