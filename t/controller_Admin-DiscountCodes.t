use strict;
use warnings;

use DateTime;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;


my $uri = '/admin/subscriptions/tabs/discount_codes';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );
my $group = $mech->_app->model('Chargemonk::SubscriptionGroup')->search( {name => '__test'} )->first();

$mech->get_ok("$uri/0");
$mech->content_contains( 'Login', 'Requres login' );

$mech->post( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );

# Create the first test campaign C1
my $c1_data = {
    name                 => '___test_campaign_c1',
    prefix               => '_c1_',
    nr_of_codes          => 2,
    start_date           => DateTime->now()->ymd(),
    end_date             => DateTime->now()->ymd(),
    create_campaign_form => 1,
    discount_type        => 'unit',
    discount_amount      => '200',
    valability           => DateTime->now()->add( days => 200 )->ymd(),
};

$mech->post_ok( "$uri/0", $c1_data, 'Add ___test_campaign1 to new subscription, not saved yet' );
$mech->content_contains( $c1_data->{name} );

my $c1 = $mech->_app->model('Chargemonk::Campaign')->search( {name => $c1_data->{name}} )->first();
ok( defined $c1,                 "C1 added to db" );
ok( scalar( $c1->codes() ) == 2, "C1 has two codes" );

# Add a test subscription that we can put the test campaign on
my $test_subscription_data = {
    name                    => '___test_subscription_sc1',
    subscription_type       => 'promo',
    subscription_group_id   => $group->id(),
    is_visible              => 0,
    require_company_data    => 0,
    has_auto_renew          => 0,
    access_type             => 'period',
    period                  => 30,
    period_unit             => 'Day',
    price                   => 10,
    currency                => 'EUR',
    number_of_users         => '',
    min_active_period_users => '1',
    max_active_period_users => '1',
    call_to_action          => 'Subscribe to sc1',
    has_trial               => 1,
    trial_period            => 3,
    trial_period_unit       => 'Day',
    trial_price             => 0,
    trial_currency          => 'EUR',
    require_credit_card     => 0,
    selected_group_order    => ['...+(this subscription)'],
    add_this_subscription   => 1,
    edit_this_subscription  => 1,
    added_campaigns         => "," . $c1->id(),
};
$mech->post_ok( "/admin/subscriptions/save", $test_subscription_data, 'Add SC1 with campaign C1 attached' );
$mech->content_contains("The subscription '$test_subscription_data->{name}' was created");

my $sc1_subscription =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();

ok( scalar( $sc1_subscription->campaigns() ) == 1, "SC1 has one campaign" );

# Add a new campaign that is valid 200 days, the codes can only be used within the first 30 days
my $c2_data = {
    name                 => '___test_campaign_c2',
    prefix               => '_c2_',
    nr_of_codes          => 10,
    start_date           => DateTime->now()->ymd(),
    end_date             => DateTime->now()->add( days => 30 )->ymd(),
    create_campaign_form => 1,
    discount_type        => 'percent',
    discount_amount      => '15',
    valability           => DateTime->now()->add( days => 200 )->ymd(),
};

$mech->post_ok( "$uri/" . $sc1_subscription->id(), $c2_data, 'Add ___test_campaign2 to SC2' );
$mech->content_contains( $c2_data->{name} );

my $c2 = $mech->_app->model('Chargemonk::Campaign')->search( {name => $c2_data->{name}} )->first();
ok( defined $c2, "C2 added to db" );

ok( scalar( $sc1_subscription->campaigns() ) == 2, "SC1 has two campaigns now" );

my $codes_data = {
    campaign_id         => $c2->id(),
    prefix              => 'ccc',
    nr_of_codes         => 5,
    generate_codes_form => 1,
};
$mech->post_ok( "$uri/" . $sc1_subscription->id(), $codes_data, 'Generate 5 more codes for C2' );
ok( scalar( $c2->codes() ) == 15, "C2 has 15 codes" );

$mech->get_ok('/logout');

$mech->get_ok( '/register/subscription/' . $sc1_subscription->id() );
# try first with an invalid code
my $register_data = {
    email            => '___test_email_sc1',
    password         => '___test_email_sc1',
    firstname        => '___test_email_sc1',
    lastname         => '___test_email_sc1',
    active_from_date => DateTime->now()->ymd(),
    active_to_date   => DateTime->now()->add( days => 30 )->ymd(),
    terms            => 'on',
    discount_code    => 'ttt',
};
$mech->post_ok( '/register/step-1-confirmation/subscription/' . $sc1_subscription->id,
    $register_data, 'Subscribe User' );
$mech->content_contains("Discount code not found");

$register_data->{discount_code} = $c2->codes->first->code();

$mech->post_ok( '/register/step-1-confirmation/subscription/' . $sc1_subscription->id,
    $register_data, 'Subscribe User' );
$mech->content_contains('Please verify your email address');

$mech->post( '/register/step-1-confirmation/subscription/' . $sc1_subscription->id,
    $register_data, 'Subscribe User' );
$mech->content_contains('Discount code already used');

my $link_sc1 = $mech->_app->model('Chargemonk::LinkUserSubscription')->search({ subscription_id => $sc1_subscription->id()})->first();
ok($link_sc1->amount_with_discount() == 8.5, "Discount amount percent works fine"); # 15% off from 10 == 8.5

