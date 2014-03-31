package Chargemonk::Schema::Result::Registration;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->table("registration");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "registration_id_seq",
    },
    sex                  => { data_type => "boolean", is_nullable => 1 },
    first_name           => { data_type => "boolean", is_nullable => 1 },
    last_name            => { data_type => "boolean", is_nullable => 1 },
    date_of_birth        => { data_type => "boolean", is_nullable => 1 },
    address              => { data_type => "boolean", is_nullable => 1 },
    address_2            => { data_type => "boolean", is_nullable => 1 },
    country              => { data_type => "boolean", is_nullable => 1 },
    state                => { data_type => "boolean", is_nullable => 1 },
    zip_code             => { data_type => "boolean", is_nullable => 1 },
    phone_number         => { data_type => "boolean", is_nullable => 1 },
    company_name         => { data_type => "boolean", is_nullable => 1 },
    company_address      => { data_type => "boolean", is_nullable => 1 },
    company_country      => { data_type => "boolean", is_nullable => 1 },
    company_state        => { data_type => "boolean", is_nullable => 1 },
    company_zip_code     => { data_type => "boolean", is_nullable => 1 },
    company_phone_number => { data_type => "boolean", is_nullable => 1 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->meta->make_immutable;

1;
