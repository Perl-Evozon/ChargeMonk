use utf8;
package Chargemonk::Schema::Result::Invoice;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Chargemonk::Schema::Result::Invoice

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<invoice>

=cut

__PACKAGE__->table("invoice");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'invoice_id_seq'

=head2 invoice_id

  data_type: 'varchar'
  is_nullable: 0
  size: 20

=head2 link_user_subscription_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 gateway

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 remaining_amount

  data_type: 'integer'
  is_nullable: 1

=head2 charge

  data_type: 'integer'
  is_nullable: 0

=head2 created

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "invoice_id_seq",
  },
  "invoice_id",
  { data_type => "varchar", is_nullable => 0, size => 20 },
  "link_user_subscription_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "gateway",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "remaining_amount",
  { data_type => "integer", is_nullable => 1 },
  "charge",
  { data_type => "integer", is_nullable => 0 },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<invoice_invoice_id_key>

=over 4

=item * L</invoice_id>

=back

=cut

__PACKAGE__->add_unique_constraint("invoice_invoice_id_key", ["invoice_id"]);

=head1 RELATIONS

=head2 link_user_subscription

Type: belongs_to

Related object: L<Chargemonk::Schema::Result::LinkUserSubscription>

=cut

__PACKAGE__->belongs_to(
  "link_user_subscription",
  "Chargemonk::Schema::Result::LinkUserSubscription",
  { id => "link_user_subscription_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);

=head2 user

Type: belongs_to

Related object: L<Chargemonk::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Chargemonk::Schema::Result::User",
  { id => "user_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-04 04:40:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mykCORjeCCnrhz+8gujNzg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
