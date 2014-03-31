
=head1 NAME

helper_Cron_Subscriptions

=head1 DESCRIPTION

Test the functions required for cron action: downgrade, expire, renew...

=head1 METHODS

=cut

use strict;
use warnings;

use Data::Dumper;
use DateTime;
use Storable qw( dclone );
use Test::More qw(no_plan);
use YAML::Tiny;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Chargemonk::Helpers::Common::DateTime;
use Chargemonk::Helpers::Cron::Subscriptions;
use Chargemonk::Test::Mechanize;
use Chargemonk::Test::Register;


my $gateway_config = YAML::Tiny->read('conf/gateway.yaml');
my $cron           = Chargemonk::Helpers::Cron::Subscriptions->new( simulate => 1 );
my $mech           = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );
my $uri            = '/admin/subscriptions';

use_ok('Chargemonk::Helpers::Cron::Subscriptions');

$mech->post_ok( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$mech->get_ok($uri);

my $group = $mech->_app->model('Chargemonk::SubscriptionGroup')->search( {name => '__test'} )->first();

### Scenario 1 - trial, no auto renew #######
#Add subscription:
#    Subscription name : ___test_subscription_s1
#    Subscription type : Promo
#    Subscription group : Test
#    Visibility : Admin only
#    Company Data? : No
#    Auto-renew? : No
#    Access : Period
#    Call to action : Subscribe to s1
#    Period: 30
#    Period Unit: Days
#    Trial Period : 10
#    Trial Unit : Days
#    Trial Require credit card? : No
#    Trial Price : 0
#    Trial Price Unit : EUR
# Create the subscription as 30 days before
# Go back: 30 days, trial start time
#   - nothing found
# Move forward 9 days, 1 days of trial remaining
#   - notify about trial expiration
# Move forward 1 day, trial finished
#   - trial is found as expired
#   - trial is made inactive
#   - regular subscription created

my $test_subscription_data = {
    name                    => '___test_subscription_s1',
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
    call_to_action          => 'Subscribe to s1',
    has_trial               => 1,
    trial_period            => 10,
    trial_period_unit       => 'Day',
    trial_price             => 0,
    trial_currency          => 'EUR',
    require_credit_card     => 0,
    selected_group_order    => ['...+(this subscription)'],
    add_this_subscription   => 1,
    edit_this_subscription  => 1,
};

$mech->post_ok( "$uri/save", $test_subscription_data, 'Add S1' );
my $s1_subscription =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();
ok( defined $s1_subscription, "S1 created" );

# the day the subscription was made active
my $dt = DateTime->now()->subtract( days => 10 );
$cron->datetime( dclone $dt);

my $register_user = Chargemonk::Test::Register->new(
    mech         => $mech,
    subscription => $s1_subscription->id(),
    gateway      => $gateway_config->[0]->{'default'}
);
my $user = $register_user->register_with_gateway();

# Subscribe the user to the subscription
#my $link_subscription_s1 = $mech->_app->model('Chargemonk::LinkUserSubscription')->find_or_create(
#    {   user_id            => $user->id(),
#        subscription_id    => $s1_subscription->id(),
#        nr_of_period_users => 1,
#        active_from_date   => timestamp($dt),
#        active_to_date     => timestamp( $dt->add( days => $test_subscription_data->{trial_period} ) ),
#        active             => 1,
#        cancelled          => 0,
#    }
#);
my $link_subscription_s1 = $mech->_app->model('Chargemonk::LinkUserSubscription')->search(
    {   user_id         => $user->id(),
        subscription_id => $s1_subscription->id(),
    }
)->first();    # link subscription created by the register_with_gateway
my $link_dates = {
    active_from_date => timestamp($dt),
    active_to_date   => timestamp( $dt->add( days => $test_subscription_data->{trial_period} ) ),
};
$link_subscription_s1->update($link_dates);

my $handled = $cron->run();

ok( ( !grep { $_->{subscription}->subscription_id() == $s1_subscription->id() } @$handled ),
    "Run for the day created, subscription not found" );

# Subscription is about to expire, one day before
$cron->datetime->add( days => 9 );
$handled = $cron->run();

my $expiring_s1 = [grep { $_->{subscription}->subscription_id() == $s1_subscription->id() } @$handled]->[0];
ok( defined $expiring_s1, "Subscription found, one day before trial ends" );
ok( $expiring_s1->{process_message} eq 'notify_expiring_trial_period',
    'Process message is notify_expiring_trial_period' );

$cron->datetime->add( days => 1 );
$handled = $cron->run();

my $expired_s1 = [grep { $_->{subscription}->id() == $expiring_s1->{subscription}->id() } @$handled]->[0];
ok( defined $expired_s1,                               "Expired subscription found" );
ok( $expired_s1->{process_message} eq 'expired_trial', "Process message is expired_trial" );
ok( $expired_s1->{process_status} = 1, "Process status is 1" );

my $new_regular_subscription = $mech->_app->model('Chargemonk::LinkUserSubscription')->search(
    {   user_id          => $expired_s1->{subscription}->user_id(),
        active           => 1,
        active_from_date => {'>=', timestamp( $cron->datetime )},
    }
)->first();
ok( defined $new_regular_subscription, "New regular subscription found" );

# reload the object to check if is made inactive
$link_subscription_s1 = $mech->_app->model('Chargemonk::LinkUserSubscription')->find( $link_subscription_s1->id() );
ok( $link_subscription_s1->active() == 0, "Trial subscription made inactive" );

$user->delete();

### End Scenario 1 ###

#exit;

### Scenario 2 - regular subscription, not trial, no auto renew #######
#Add subscription:
#    Subscription name : ___test_subscription_s2
#    Subscription type : Promo
#    Subscription group : Test
#    Visibility : Admin only
#    Company Data? : No
#    Auto-renew? : No
#    Access : Period
#    Call to action : Subscribe to s2
#    Period: 60
#    Period Unit: Days
# Create the subscription as 60 days before
# Go back: 40 days
#   - nothing found
# Go forward: 10 days( 10 days till expire)
#   - nothing found
# Move forward 9 days, 1 day remaining
#   - notify about subscription expiration
# Move forward 1 day, subscription expired
#   - expired subscription marked as expired

{
    my $test_subscription_data = {
        name                    => '___test_subscription_s2',
        subscription_type       => 'promo',
        subscription_group_id   => $group->id(),
        is_visible              => 0,
        require_company_data    => 0,
        has_auto_renew          => 0,
        access_type             => 'period',
        period                  => 60,
        period_unit             => 'Day',
        price                   => 10,
        currency                => 'EUR',
        number_of_users         => '',
        min_active_period_users => '1',
        max_active_period_users => '1',
        call_to_action          => 'Subscribe to s2',
        has_trial               => 0,
        trial_period            => 10,                        # requires triad period and period unit because it's promo
        trial_period_unit       => 'Day',
        require_credit_card     => 0,
        selected_group_order   => ['...+(this subscription)'],
        add_this_subscription  => 1,
        edit_this_subscription => 1,
    };

    $mech->post_ok( "$uri/save", $test_subscription_data,
        'Add S2 - regular subscription, 60 days, no trial, no auto renew' );
    my $s2_subscription =
        $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();
    ok( defined $s2_subscription, "S2 created" );

    $register_user = Chargemonk::Test::Register->new(
        mech         => $mech,
        subscription => $s2_subscription->id(),
        gateway      => $gateway_config->[0]->{'default'}
    );
    my $test_user = $register_user->register_with_gateway();

    #warn Dumper($test_user);

    # the day th1e subscription was made active
    my $dt = DateTime->now()->subtract( days => 60 );
    $cron->datetime( dclone $dt);

    # Search the link subscription created by the register_with_gateway
    my $link_subscription_s2 = $mech->_app->model('Chargemonk::LinkUserSubscription')->search(
        {   user_id         => $test_user->id(),
            subscription_id => $s2_subscription->id(),
        }
    )->first();
    $link_subscription_s2->update(
        {   nr_of_period_users => 1,
            active_from_date   => timestamp($dt),
            active_to_date     => timestamp( $dt->add( days => $test_subscription_data->{period} ) ),
            active             => 1,
            cancelled          => 0,
        }
    );

    $s2_subscription->update( {created => timestamp($dt)} );

    $cron->datetime->add( days => 40 );
    my $handled = $cron->run();

    ok( ( !grep { $_->{subscription}->subscription_id() == $s2_subscription->id() } @$handled ),
        "Run after 40 days, subscription not found" );

    $cron->datetime->add( days => 10 );
    $handled = $cron->run();

    ok( ( !grep { $_->{subscription}->subscription_id() == $s2_subscription->id() } @$handled ),
        "Run after 50 days, subscription not found" );

    $cron->datetime->add( days => 9 );
    $handled = $cron->run();

    my $expiring_s2 = [grep { $_->{subscription}->subscription_id() == $s2_subscription->id() } @$handled]->[0];
    ok( defined $expiring_s2, "Subscription S2 found, one day before expiring" );
    ok( $expiring_s2->{process_message} eq 'notify_expiring_subscription',
        'Process message is notify_expiring_subscription' );

    $cron->datetime->add( days => 1 );
    $handled = $cron->run();

    my $expired_s2 = [grep { $_->{subscription}->id() == $expiring_s2->{subscription}->id() } @$handled]->[0];
    ok( defined $expired_s2,                                      "Expired subscription found" );
    ok( $expired_s2->{process_message} eq 'expired_subscription', "Process message is expired_subscription" );
    ok( $expired_s2->{process_status} = 1, "Process status is 1" );

    $test_user->delete();
}

### End Scenario 2 ###


### Scenario 3 - auto renew #######
#Add subscription:
#    Subscription name : ___test_subscription_s3
#    Subscription type : Promo
#    Subscription group : Test
#    Visibility : Admin only
#    Company Data? : No
#    Auto-renew? : Yes
#    Access : Period
#    Call to action : Subscribe to s3
#    Period: 60
#    Period Unit: Days
# Create the subscription as 60 days before
# Go back: 40 days
#   - nothing found
# Move forward 19 days, 1 day remaining
#   - notify about subscription renew
# Move forward 1 day, subscription expired
#   - expired subscription marked as expired
#   - new link subscription found

{
    my $test_subscription_data = {
        name                    => '___test_subscription_s3',
        subscription_type       => 'promo',
        subscription_group_id   => $group->id(),
        is_visible              => 0,
        require_company_data    => 0,
        has_auto_renew          => 1,
        access_type             => 'period',
        period                  => 60,
        period_unit             => 'Day',
        price                   => 10,
        currency                => 'EUR',
        number_of_users         => '',
        min_active_period_users => '1',
        max_active_period_users => '1',
        call_to_action          => 'Subscribe to s3',
        has_trial               => 0,
        trial_period            => 10,                        # requires triad period and period unit because it's promo
        trial_period_unit       => 'Day',
        require_credit_card     => 0,
        selected_group_order   => ['...+(this subscription)'],
        add_this_subscription  => 1,
        edit_this_subscription => 1,
    };

    $mech->post_ok( "$uri/save", $test_subscription_data, 'Add S3 - regular subscription, 60 days, auto renew' );
    my $s3_subscription =
        $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();
    ok( defined $s3_subscription, "S3 created" );

    my $gateway_config = YAML::Tiny->read('conf/gateway.yaml');
    my $register_user  = Chargemonk::Test::Register->new(
        mech         => $mech,
        subscription => $s3_subscription->id(),
        gateway      => $gateway_config->[0]->{'default'}
    );
    my $test_user = $register_user->register_with_gateway();

    # the day th1e subscription was made active
    my $dt = DateTime->now()->subtract( days => 60 );
    $cron->datetime( dclone $dt);

    # Search the link subscription created by the register_with_gateway
    my $link_subscription_s3 = $mech->_app->model('Chargemonk::LinkUserSubscription')->search(
        {   user_id         => $test_user->id(),
            subscription_id => $s3_subscription->id(),
        }
    )->first();
    $link_subscription_s3->update(
        {   nr_of_period_users => 1,
            active_from_date   => timestamp($dt),
            active_to_date     => timestamp( $dt->add( days => $test_subscription_data->{period} ) ),
            active             => 1,
            cancelled          => 0,
        }
    );

    $s3_subscription->update( {created => timestamp($dt)} );

    $cron->datetime->add( days => 40 );
    my $handled = $cron->run();

    ok( ( !grep { $_->{subscription}->subscription_id() == $s3_subscription->id() } @$handled ),
        "Run after 40 days, subscription not found" );

    $cron->datetime->add( days => 19 );
    $handled = $cron->run();

    my $expiring_s3 = [grep { $_->{subscription}->subscription_id() == $s3_subscription->id() } @$handled]->[0];
    ok( defined $expiring_s3,                                   "Subscription S3 found, one day before expiring" );
    ok( $expiring_s3->{process_message} eq 'notify_auto_renew', 'Process message is notify_auto_renew' );

    $cron->datetime->add( days => 1 );
    $handled = $cron->run();

    my $expired_s3 = [grep { $_->{subscription}->id() == $expiring_s3->{subscription}->id() } @$handled]->[0];
    ok( defined $expired_s3,                                    "Expired subscription found" );
    ok( $expired_s3->{process_message} eq 'expired_auto_renew', "Process message is expired_auto_renew" );
    ok( $expired_s3->{process_status} = 1, "Process status is 1" );

    my $new_regular_subscription = $mech->_app->model('Chargemonk::LinkUserSubscription')->search(
        {   user_id          => $expired_s3->{subscription}->user_id(),
            active           => 1,
            active_from_date => {'>=', timestamp( $cron->datetime )},
        }
    )->first();
    ok( defined $new_regular_subscription, "The new link subscription found" );

    # reload the object to check if is made inactive
    $link_subscription_s3 = $mech->_app->model('Chargemonk::LinkUserSubscription')->find( $link_subscription_s3->id() );
    ok( $link_subscription_s1->active() == 0, "Old subscription made inactive" );

    $test_user->delete();
}

### End Scenario 3 ###


### Scenario 4 - downgrade #######
#Add subscription:
#    Subscription name : ___test_subscription_s4
#    Subscription type : Promo
#    Subscription group : Test
#    Visibility : Admin only
#    Company Data? : No
#    Auto-renew? : No
#    Access : Period
#    Call to action : Subscribe to s4
#    Period: 60
#    Period Unit: Days
# Create the subscription as 60 days before
# Create the link subscription for downgrade to s1
# Go back: 40 days
#   - nothing found
# Move forward 19 days, 1 day remaining
#   - notify about subscription downgrade
# Move forward 1 day, subscription expired
#   - expired subscription marked as expired
#   - downgrade subscription activated

{
    my $test_subscription_data = {
        name                    => '___test_subscription_s4',
        subscription_type       => 'promo',
        subscription_group_id   => $group->id(),
        is_visible              => 0,
        require_company_data    => 0,
        has_auto_renew          => 0,
        access_type             => 'period',
        period                  => 60,
        period_unit             => 'Day',
        price                   => 10,
        currency                => 'EUR',
        number_of_users         => '',
        min_active_period_users => '1',
        max_active_period_users => '1',
        call_to_action          => 'Subscribe to s4',
        has_trial               => 0,
        trial_period            => 10,                        # requires triad period and period unit because it's promo
        trial_period_unit       => 'Day',
        require_credit_card     => 0,
        selected_group_order   => ['...+(this subscription)'],
        add_this_subscription  => 1,
        edit_this_subscription => 1,
    };

    $mech->post_ok( "$uri/save", $test_subscription_data,
        'Add S4 - regular subscription, 60 days, downgrade to s1, no auto renew, no trial' );
    my $s4_subscription =
        $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();
    ok( defined $s4_subscription, "S4 created" );

    my $gateway_config = YAML::Tiny->read('conf/gateway.yaml');
    my $register_user  = Chargemonk::Test::Register->new(
        mech         => $mech,
        subscription => $s4_subscription->id(),
        gateway      => $gateway_config->[0]->{'default'}
    );
    my $test_user = $register_user->register_with_gateway();

    # the day th1e subscription was made active
    my $dt = DateTime->now()->subtract( days => 60 );
    $cron->datetime( dclone $dt);

    # Search the link subscription created by the register_with_gateway
    my $link_subscription_s4 = $mech->_app->model('Chargemonk::LinkUserSubscription')->search(
        {   user_id         => $test_user->id(),
            subscription_id => $s4_subscription->id(),
        }
    )->first();
    $link_subscription_s4->update(
        {   nr_of_period_users => 1,
            active_from_date   => timestamp($dt),
            active_to_date     => timestamp( $dt->add( days => $test_subscription_data->{period} ) ),
            active             => 1,
            cancelled          => 0,
        }
    );

    my $link_subscription_s4_down_to_s1 = $mech->_app->model('Chargemonk::LinkUserSubscription')->create(
        {   user_id            => $test_user->id(),
            subscription_id    => $s1_subscription->id(),
            nr_of_period_users => 1,
            active_from_date   => timestamp( DateTime->now() ),
            active_to_date     => timestamp( DateTime->now()->add( days => $s1_subscription->period() ) ),
            active             => 0,
            cancelled          => 0,
        }
    );
    $s4_subscription->update( {created => timestamp($dt)} );

    $cron->datetime->add( days => 40 );
    my $handled = $cron->run();

    ok( ( !grep { $_->{subscription}->subscription_id() == $s4_subscription->id() } @$handled ),
        "Run after 40 days, subscription not found" );

    $cron->datetime->add( days => 19 );
    $handled = $cron->run();

    my $expiring_s4 = [grep { $_->{subscription}->subscription_id() == $s4_subscription->id() } @$handled]->[0];
    ok( defined $expiring_s4, "Subscription S4 found, one day before expiring" );
    my $msg = 'notify_downgrading';
    ok( $expiring_s4->{process_message} eq $msg, 'Process message is ' . $msg );

    $cron->datetime->add( days => 1 );
    $handled = $cron->run();

    my $expired_s4 = [grep { $_->{subscription}->id() == $expiring_s4->{subscription}->id() } @$handled]->[0];
    ok( defined $expired_s4,                                    "Expired subscription found" );
    ok( $expired_s4->{process_message} eq 'expired_downgraded', "Process message is expired_downgraded" );
    ok( $expired_s4->{process_status} = 1, "Process status is 1" );

    # reload the object to check if is made inactive
    $link_subscription_s4_down_to_s1 =
        $mech->_app->model('Chargemonk::LinkUserSubscription')->find( $link_subscription_s4_down_to_s1->id() );
    ok( $link_subscription_s4_down_to_s1->active() == 1, "Downgraded subscription made active" );

    $test_user->delete();
}

### End Scenario 4 ###

