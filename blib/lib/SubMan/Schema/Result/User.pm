package SubMan::Schema::Result::User;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
use MooseX::NonMoose;
use DateTime;
use utf8;

extends 'DBIx::Class::Core';

__PACKAGE__->load_components(qw/InflateColumn::DateTime PassphraseColumn/);

__PACKAGE__->table("user");

__PACKAGE__->add_columns(
    id => {
        data_type         => "integer",
        is_auto_increment => 1,
        is_nullable       => 0,
        sequence          => "user_id_seq",
    },
    firstname        => {data_type => "varchar", is_nullable    => 1, size        => 100},
    lastname         => {data_type => "varchar", is_nullable    => 1, size        => 100},
    email            => {data_type => "varchar", is_nullable    => 0, size        => 50},
    address          => {data_type => "varchar", is_nullable    => 1, size        => 200},
    address2         => {data_type => "varchar", is_nullable    => 1, size        => 200},
    country          => {data_type => "varchar", is_nullable    => 1, size        => 50},
    state            => {data_type => "varchar", is_nullable    => 1, size        => 50},
    zip_code         => {data_type => "varchar", is_nullable    => 1, size        => 10},
    phone            => {data_type => "varchar", is_nullable    => 1, size        => 15},
    gender           => {data_type => "varchar", is_nullable    => 1, size        => 1},
    company_name     => {data_type => "varchar", is_nullable    => 1, size        => 100},
    company_address  => {data_type => "varchar", is_nullable    => 1, size        => 200},
    company_country  => {data_type => "varchar", is_nullable    => 1, size        => 50},
    company_state    => {data_type => "varchar", is_nullable    => 1, size        => 50},
    company_zip_code => {data_type => "varchar", is_nullable    => 1, size        => 10},
    company_phone    => {data_type => "varchar", is_nullable    => 1, size        => 15},
    profile_picture  => {data_type => "varchar", is_nullable    => 1, size        => 250},
    user_type        => {
        data_type     => "enum",
        default_value => "LEAD",
        extra         => {
            custom_type_name => "user_type",
            list             => ["ADMIN", "CUSTOMER", "LEAD"],
        },
        is_nullable => 0,
    },
    birthday    => {data_type => "date", is_nullable => 1},
    password => {
        data_type        => "varchar",
        is_nullable      => 1,
        size             => 64,
        passphrase       => 'crypt',
        passphrase_class => 'BlowfishCrypt',
        passphrase_args  => {
            cost        => 12,
            salt_random => 1,
        },
        passphrase_check_method => 'check_password',
    },
    "signup_date" =>  {
        data_type     => "timestamp",
        default_value => \"current_timestamp",
        is_nullable   => 0,
        original      => { default_value => \"now()" },
    },
);

__PACKAGE__->set_primary_key("id");

__PACKAGE__->add_unique_constraint( "user_email_key", ["email"] );

__PACKAGE__->has_many(
    "link_user_subscription", "SubMan::Schema::Result::LinkUserSubscription",
    {"foreign.user_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

__PACKAGE__->has_many(
    "campaigns", "SubMan::Schema::Result::Campaign",
    {"foreign.user_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

__PACKAGE__->might_have(
    "user_psw_set_token", "SubMan::Schema::Result::UserPswSetToken",
    {"foreign.uid" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

__PACKAGE__->might_have(
    "user_registration_token", "SubMan::Schema::Result::UserRegistrationToken",
    {"foreign.user_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

__PACKAGE__->might_have(
    "discount_codes", "SubMan::Schema::Result::Code",
    {"foreign.user_id" => "self.id"}, {cascade_copy => 0, cascade_delete => 0},
);

sub has_period_users_subscription {
    my ($self) = @_;

    my @subscriptions = $self->link_user_subscription->all;
    foreach (@subscriptions) {
        return $_->subscription->id if $_->subscription->access_type eq 'period_users';
    }

    return;
}

sub has_ip_range_subscription {
    my ($self) = @_;

    my @subscriptions = $self->link_user_subscription->all;
    foreach (@subscriptions) {
        return $_->subscription->id if $_->subscription->access_type eq 'IP_range';
    }

    return;
}

=head 2

delete

Delete relations before deleting the record itself otherwise it'll crash because of the db onstraint
The dbix cascade_delete is trying to delete the related after deleting the record itself, looks to be a dbix bug

=cut

sub delete {
    my ( $self, @args ) = @_;

    $self->delete_related('user_psw_set_token');
    $self->delete_related('user_registration_token');
    $self->delete_related('link_user_subscription');
    $self->delete_related('campaigns');
    $self->delete_related('discount_codes');

    $self->next::method(@args);
}

__PACKAGE__->meta->make_immutable;

1;
