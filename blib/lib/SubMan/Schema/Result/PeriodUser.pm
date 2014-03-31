package SubMan::Schema::Result::PeriodUser;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

__PACKAGE__->table("period_user");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "period_user_id_seq",
    },
    link_user_subscription_id =>
      { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
    subscription_id =>
      { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
    first_name => { data_type => "varchar", is_nullable => 0, size => 30 },
    last_name  => { data_type => "varchar", is_nullable => 0, size => 30 },
    email      => { data_type => "varchar", is_nullable => 0, size => 50 },
    start_date => {
        data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
        original      => { default_value => \"now()" },
    },
    status =>
      { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
    "link_user_subscription",
    "SubMan::Schema::Result::LinkUserSubscription",
    { id            => "link_user_subscription_id" },
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
