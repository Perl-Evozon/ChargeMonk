package SubMan::Schema::Result::Theme;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->table("theme");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "theme_id_seq",
    },
    name       => { data_type => "varchar", is_nullable => 0, size => 100 },
    css_file   => { data_type => "varchar", is_nullable => 0, size => 128 },
    image_file => { data_type => "varchar", is_nullable => 0, size => 128 },
    active =>
      { data_type => "boolean", default_value => \"false", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->meta->make_immutable;

1;
