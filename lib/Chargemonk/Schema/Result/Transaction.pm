use utf8;
package Chargemonk::Schema::Result::Transaction;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Chargemonk::Schema::Result::Transaction

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<transaction>

=cut

__PACKAGE__->table("transaction");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'transaction_id_seq'

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 link_user_subscription_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 gateway

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 tranzaction_id

  data_type: 'varchar'
  is_nullable: 1
  size: 20

=head2 created

  data_type: 'timestamp'
  default_value: current_timestamp
  is_nullable: 0
  original: {default_value => \"now()"}

=head2 amount

  data_type: 'integer'
  is_nullable: 0

=head2 success

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 action

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 response_text

  data_type: 'varchar'
  is_nullable: 1
  size: 500

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "transaction_id_seq",
  },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "link_user_subscription_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "gateway",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "tranzaction_id",
  { data_type => "varchar", is_nullable => 1, size => 20 },
  "created",
  {
    data_type     => "timestamp",
    default_value => \"current_timestamp",
    is_nullable   => 0,
    original      => { default_value => \"now()" },
  },
  "amount",
  { data_type => "integer", is_nullable => 0 },
  "success",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "action",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "response_text",
  { data_type => "varchar", is_nullable => 1, size => 500 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

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


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-01 08:04:52
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IRQm/60K++43cxlmAMxt8Q


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
