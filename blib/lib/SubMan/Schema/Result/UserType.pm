package SubMan::Schema::Result::UserType;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("user_type");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "user_type_id_seq",
    },
    user_type => { data_type => "varchar", is_nullable => 0, size => 10 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint( "user_type_type_key", ["user_type"] );

__PACKAGE__->has_many(
    "users",
    "SubMan::Schema::Result::User",
    { "foreign.type_id" => "self.id" },
    { cascade_copy      => 0, cascade_delete => 0 },
);

__PACKAGE__->meta->make_immutable;

1;
