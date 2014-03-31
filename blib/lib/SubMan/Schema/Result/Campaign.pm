package SubMan::Schema::Result::Campaign;

use strict;
use warnings;
use utf8;
use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'DBIx::Class::Core';

__PACKAGE__->table("campaign");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "campaign_id_seq",
    },
    name            => {data_type => "varchar", is_nullable   => 0, size        => 50},
    prefix          => {data_type => "varchar", is_nullable   => 0, size        => 5},
    nr_of_codes     => {data_type => "integer", default_value => 0, is_nullable => 0},
    start_date      => {data_type => "date",    is_nullable   => 1},
    end_date        => {data_type => "date",    is_nullable   => 1},
    "discount_type" => {
        data_type   => "enum",
        extra       => {custom_type_name => "discount", list => ["unit", "percent"]},
        is_nullable => 1,
    },
    "discount_amount" => {data_type => "integer", is_nullable    => 0},
    "valability"      => {data_type => "date",    is_nullable    => 1},
    user_id           => {data_type => "integer", is_foreign_key => 1, is_nullable => 0},
    subscription_id   => {data_type => "integer", is_foreign_key => 1, is_nullable => 1}, # cna be null when it's linked to a subscription that isn't saved yet
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->belongs_to(
    "subscription",
    "SubMan::Schema::Result::Subscription",
    {id            => "subscription_id"},
    {is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE"},
);

__PACKAGE__->belongs_to(
    "user",
    "SubMan::Schema::Result::User",
    {id            => "user_id"},
    {is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE"},
);

__PACKAGE__->has_many(
    "codes",
    "SubMan::Schema::Result::Code",
    {"foreign.campaign_id" => "self.id"},
    {cascade_copy          => 0, cascade_delete => 0},
);


=head 2

delete

Delete relations before deleting the record itself otherwise it'll crash because of the db onstraint
The dbix cascade_delete is trying to delete the related after deleting the record itself, looks to be a dbix bug

=cut

sub delete {
    my ( $self, @args ) = @_;

    $self->delete_related('codes');

    $self->next::method(@args);
}

__PACKAGE__->meta->make_immutable;

1;
