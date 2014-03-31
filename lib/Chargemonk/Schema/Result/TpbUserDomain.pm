package Chargemonk::Schema::Result::TpbUserDomain;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("tpb_user_domain");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        size              => 6,
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "user_type_id_seq",
    },
    user_id => { data_type => "integer", is_nullable => 0, size => 11 },
    domain  => { data_type => "varchar", is_nullable => 0, size => 200 }
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint( "tpb_user_domain_idx_user_id", ["user_id"] );

__PACKAGE__->meta->make_immutable;

1;
