use strict;
use warnings;

use DateTime;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;


my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->post( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );


# TODO: test individual vs corporate


$mech->get_ok("/admin/subscriptions/add_subscription");

# Add IPs subscription
my $test_subscription_data = {
    name                    => '___test_subscription_ips',
    subscription_type       => 'regular',
    subscription_group_id   => 1,                            # Default
    is_visible              => 0,
    require_company_data    => 0,
    has_auto_renew          => 1,
    access_type             => 'IP_range',
    period                  => 2,
    period_unit             => 'Day',
    price                   => 10,
    currency                => 'EUR',
    number_of_users         => '',
    min_active_period_users => '',
    call_to_action          => 'Subscribe!',
    has_trial               => 0,
    require_credit_card     => 1,
    selected_group_order    => 'IP+range',
    selected_group_order    => '...+(this+subscription)',
    add_this_subscription   => 1,
    min_active_ips          => 1,
    max_active_ips          => 2,

};
$mech->post( "/admin/subscriptions/save", $test_subscription_data );
my $ips_subscription =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();

#use Data::Dumper;
#warn Dumper($ips_subscription);

# logout admin as we need to register user for ips subscription
$mech->post('/logout');

# Subscribe user to this subscription
my $test_user_data = {
    email            => 'dummy@dummy.com',
    password         => 'dummy',
    firstname        => 'Test',
    lastname         => 'User',
    active_from_date => DateTime->now()->strftime("%Y-%m-%d"),
    active_to_date   => DateTime->now()->strftime("%Y-%m-%d"),
    terms            => 'on',
};
$mech->post( 'register/step-1-confirmation/subscription/' . $ips_subscription->id(), $test_user_data, );
$mech->content_contains('Please verify your email address');

my $user = $mech->_app->model('Chargemonk::User')->search( {email => $test_user_data->{email}} )->first();

# login admin so we can test manage ips on the registered user
$mech->post( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );

$mech->get_ok( '/admin/manage_ips/' . $user->id() . '?subscription_id=' . $ips_subscription->id() );
$mech->content_like(qr{Manage IPs for.*$test_user_data->{firstname}\s$test_user_data->{lastname}});

# Cleanup
$user->delete();
$ips_subscription->delete();
