use utf8;
package Chargemonk::Schema::Result::AuthorizeUser;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Chargemonk::Schema::Result::AuthorizeUser

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<authorize_user>

=cut

__PACKAGE__->table("authorize_user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'authorize_user_id_seq'

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "authorize_user_id_seq",
  },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "customer_id",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "card_type",
  { data_type => "varchar", is_nullable => 1, size => 30},
  "last_four",
  { data_type => "varchar", is_nullable => 1, size => 4},
  "expiration_date",
  { data_type => "date", is_nullable => 1 }
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

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


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-02 08:18:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9Y9p4VzVzL9/NPRo71lUoQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
