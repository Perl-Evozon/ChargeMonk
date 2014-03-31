use strict;
use warnings;

use FindBin;
use YAML::Tiny;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;
use Chargemonk::Test::Register;

use Chargemonk::Helpers::Gateways::Stripe;
use Chargemonk::Helpers::Gateways::Braintree;
use Chargemonk::Helpers::Gateways::Authorize;

my $uri_create_subscription = '/admin/subscriptions';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->post_ok( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$mech->get_ok($uri_create_subscription);
$mech->base_like(qr/$uri_create_subscription/);

############### Step 1 #####################
####### Create subscrition group ###########

$mech->post_ok( $uri_create_subscription, {name => '__test_group', create_this_group => 1}, 'Add group' );

my $group = $mech->_app->model('Chargemonk::SubscriptionGroup')->search( {name => '__test_group'} )->first();

############### Step 2 #####################
####### Create 3 subscriptions  ############
# A main subscrioption for a user to subscribe to
# A subscription for the user to upgrade to
# A subscription for the user to downgrade to

$mech->get_ok("$uri_create_subscription/save");

my $test_subscription_data_downgrade = {
    name                        => '___test_subscription_downgrade',
    subscription_type           => 'regular',
    subscription_group_id       => $group->id(),
    is_visible                  => 1,
    require_company_data        => 0,
    has_auto_renew              => 1,
    access_type                 => 'period',
    period                      => 10,
    period_unit                 => 'Week',
    price                       => 550,
    currency                    => 'EUR',
    number_of_users             => '',
    min_active_period_users     => '',
    max_active_period_users     => '',
    call_to_action              => 'Subscribe!',
    has_trial                   => 0,
    require_credit_card         => 1,
    selected_group_order        => ['...+(this subscription)'],
    add_this_subscription       => 1,
};

$mech->post_ok( "$uri_create_subscription/save", $test_subscription_data_downgrade, 'Add ___test_subscription_downgrade' );
$mech->content_contains("The subscription '$test_subscription_data_downgrade->{name}' was created");

my $subscription_downgrade =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data_downgrade->{name}} )->first();

$mech->get_ok( "$uri_create_subscription/update/" . $subscription_downgrade->id(), 'Edit page is loads fine' );



my $test_subscription_data_upgrade = {
    name                        => '___test_subscription_upgrade',
    subscription_type           => 'regular',
    subscription_group_id       => $group->id(),
    is_visible                  => 1,
    require_company_data        => 0,
    has_auto_renew              => 1,
    access_type                 => 'period',
    period                      => 10,
    period_unit                 => 'Week',
    price                       => 1800,
    currency                    => 'EUR',
    number_of_users             => '',
    min_active_period_users     => '',
    max_active_period_users     => '',
    call_to_action              => 'Subscribe!',
    has_trial                   => 0,
    require_credit_card         => 1,
    selected_group_order        => ['...+(this subscription)', '___test_subscription_downgrade', '___test_subscription_main'],
    add_this_subscription       => 1,
};

$mech->post_ok( "$uri_create_subscription/save", $test_subscription_data_upgrade, 'Add ___test_subscription_downgrade' );
$mech->content_contains("The subscription '$test_subscription_data_upgrade->{name}' was created");

my $subscription_upgrade =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data_upgrade->{name}} )->first();

$mech->get_ok( "$uri_create_subscription/update/" . $subscription_upgrade->id(), 'Edit page is loads fine' );



my $test_subscription_data_main = {
    name                        => '___test_subscription_main',
    subscription_type           => 'regular',
    subscription_group_id       => $group->id(),
    is_visible                  => 1,
    require_company_data        => 0,
    has_auto_renew              => 1,
    access_type                 => 'period',
    period                      => 10,
    period_unit                 => 'Week',
    price                       => 1500,
    currency                    => 'EUR',
    number_of_users             => '',
    min_active_period_users     => '',
    max_active_period_users     => '',
    call_to_action              => 'Subscribe!',
    has_trial                   => 0,
    require_credit_card         => 1,
    selected_group_order        => ['...+(this subscription)', '___test_subscription_downgrade'],
    selected_downgrades         => [$subscription_downgrade->id()],
    selected_upgrades           => [$subscription_upgrade->id()],
    add_this_subscription       => 1,
};

$mech->post_ok( "$uri_create_subscription/save", $test_subscription_data_main, 'Add ___test_subscription_downgrade' );
$mech->content_contains("The subscription '$test_subscription_data_main->{name}' was created");

my $subscription_main =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data_main->{name}} )->first();

$mech->get_ok( "$uri_create_subscription/update/" . $subscription_main->id(), 'Edit page is loads fine' );






############### Step 3 #####################
############# Create users #################
# add users to subscribe to different subscriptions
# one user is created using stripe and one using braintree

#logout the admin
$mech->get_ok('/logout');

my $gateway_config = YAML::Tiny->read('conf/gateway.yaml');
my $original_gateway = $gateway_config->[0]->{'default'};
$gateway_config->[0]->{'default'} = 'stripe';
$gateway_config->write('conf/gateway.yaml');

my $user_details_uri = '/admin/users/user_details/';
my $upgrade_downgrade_uri = '/common/subscriptionactions/';
#set gateway to stripe and test

foreach my $gateway ( 'braintree', 'stripe', 'authorize' ) {
    my $register_user = Chargemonk::Test::Register->new( mech => $mech, subscription => $subscription_main->id(), gateway => $gateway );
    my $test_user = $register_user->register_with_gateway();
    
    $gateway_config->[0]->{'default'} = $gateway;
    $gateway_config->write('conf/gateway.yaml');

    my $test_user_link_subscription =
        $mech->_app->model('Chargemonk::LinkUserSubscription')->search( {user_id => $test_user->id , subscription_id => $subscription_main->id()} )->first();
    ok( $test_user_link_subscription , 'Found main link_subscription in database');
    
    $mech->get_ok('/logout');
    $mech->post_ok( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
    

    # Check user_details 
    $mech->get_ok( $user_details_uri .''. $test_user->id);
    $mech->content_contains( $test_user->email );
    $mech->content_contains( $test_user->firstname.' '.$test_user->lastname );
    
    $mech->content_like(qr/<i class=\"icon icon-upload\">\s*<\/i>\s*Upgrade\s*<\/button>/s);

#warn $mech->content();    
#exit;

    $mech->content_like(qr/<i class=\"icon icon-download\">\s*<\/i>\s*Downgrade\s*<\/button>/s);
    $mech->content_contains( "___test_subscription_main" );
    
    ################### case 1
    ###################upgrade subscription
    $mech->get_ok( $upgrade_downgrade_uri .'upgrade_choose/' .$test_user->id .'/'.$test_user_link_subscription->id);
    
    $mech->content_contains( "Choose subscription to upgrade to");
    $mech->post_ok( $upgrade_downgrade_uri .'upgrade/' .$test_user->id .'/'.$test_user_link_subscription->id,
                   { subscription => $subscription_upgrade->id },
                   'choose upgrade'
                   );
    $mech->content_contains( "Upgrade Details");
    $mech->content_contains( "___test_subscription_main");
    $mech->content_contains( "___test_subscription_upgrade");
    
    $mech->post_ok( $upgrade_downgrade_uri .'upgrade_save/' .$test_user->id .'/'.$test_user_link_subscription->id,
                   { subscription => $subscription_upgrade->id,
                        upgrade   => 'save'
                    },
                   'save subscribe'
                   );
    $mech->content_contains( "Payment completed successfully");
    
    
    $mech->get_ok( $user_details_uri .''. $test_user->id);
    $mech->content_unlike(qr/<i class=\"icon icon-upload\">\s*<\/i>\s*Upgrade\s*<\/button>/s);
    $mech->content_unlike(qr/<i class=\"icon icon-download\">\s*<\/i>\s*Downgrade\s*<\/button>/s);
    $mech->content_contains( "___test_subscription_main" );
    $mech->content_contains( "___test_subscription_upgrade" );
    
    my $test_user_link_subscription_new =
        $mech->_app->model('Chargemonk::LinkUserSubscription')->search( {user_id => $test_user->id , subscription_id => $subscription_upgrade->id()} )->first();
    ok( $test_user_link_subscription_new , 'Found upgrade link_subscription in database');
    $test_user_link_subscription_new->update({ active => 0});
    
    
    $mech->get_ok( $user_details_uri .''. $test_user->id);
    $mech->content_unlike(qr/<i class=\"icon icon-upload\">\s*<\/i>\s*Upgrade\s*<\/button>/s);
    $mech->content_unlike(qr/<i class=\"icon icon-download\">\s*<\/i>\s*Downgrade\s*<\/button>/s);
    $mech->content_like(qr/<i class=\"icon icon-refresh\">\s*<\/i>\s*Renew\s*<\/button>/s);
    
    ################### case 2
    ################### renew subscription
    $mech->get_ok( $upgrade_downgrade_uri .'renew/' .$test_user->id .'/'.$subscription_upgrade->id());
    $mech->content_contains( "Renew Subscription Details" );
    $mech->post_ok( $upgrade_downgrade_uri .'renew_save/' .$test_user->id .'/'.$subscription_upgrade->id(),
                   {
                        upgrade   => 'save'
                    },
                   'save renew'
                   );
    $mech->content_contains( "Payment completed successfully");
    
    $mech->get_ok( $user_details_uri .''. $test_user->id);
    $mech->content_unlike(qr/<i class=\"icon icon-upload\">\s*<\/i>\s*Upgrade\s*<\/button>/s);
    $mech->content_unlike(qr/<i class=\"icon icon-download\">\s*<\/i>\s*Downgrade\s*<\/button>/s);
    $mech->content_unlike(qr/<i class=\"icon icon-refresh\">\s*<\/i>\s*Renew\s*<\/button>/s);
    #reset all subscriptions
    my $test_user_link_subscription_all_upgrades =
        $mech->_app->model('Chargemonk::LinkUserSubscription')->search( {user_id => $test_user->id } )->update_all({ active => 0, cancelled => 1 });
        
    $test_user_link_subscription =
        $mech->_app->model('Chargemonk::LinkUserSubscription')->search( {user_id => $test_user->id , subscription_id => $subscription_main->id()} )->first();
    $test_user_link_subscription->update({ active => 1 , cancelled => 0 });
    
    $mech->get_ok( $user_details_uri .''. $test_user->id);
    $mech->content_like(qr/<i class=\"icon icon-upload\">\s*<\/i>\s*Upgrade\s*<\/button>/s);
    $mech->content_like(qr/<i class=\"icon icon-download\">\s*<\/i>\s*Downgrade\s*<\/button>/s);

    ################### case 3
    ################### cancel subscription
    $mech->post_ok( $user_details_uri .$test_user->id,
               { cancel_subscription => 1,
                link_user_subscription_id   => $test_user_link_subscription->id
                },
               'cancel subscription'
               );
    $mech->content_contains( "The current subscription for this user was cancelled");

    ################### case 4
    ################### downgrade subscription
    $mech->get_ok( $upgrade_downgrade_uri .'downgrade_choose/' .$test_user->id .'/'.$test_user_link_subscription->id);
    
    $mech->content_contains( "Choose subscription to downgrade to");
    $mech->post_ok( $upgrade_downgrade_uri .'downgrade/' .$test_user->id .'/'.$test_user_link_subscription->id,
                   { subscription => $subscription_downgrade->id },
                   'choose upgrade'
                   );
    $mech->content_contains( "Downgrade Details");
    $mech->content_contains( "___test_subscription_main");
    $mech->content_contains( "___test_subscription_downgrade");
    
    $mech->post_ok( $upgrade_downgrade_uri .'downgrade_save/' .$test_user->id .'/'.$test_user_link_subscription->id,
                   { subscription => $subscription_downgrade->id,
                     downgrade   => 'save'
                    },
                   'save subscribe'
                   );
    $mech->content_contains( "Subscription saved successfully");
    
    
    $mech->get_ok( $user_details_uri .''. $test_user->id);
    $mech->content_unlike(qr/<i class=\"icon icon-upload\">\s*<\/i>\s*Upgrade\s*<\/button>/s);
    $mech->content_unlike(qr/<i class=\"icon icon-download\">\s*<\/i>\s*Downgrade\s*<\/button>/s);
    $mech->content_unlike(qr/<i class=\"icon icon-refresh\">\s*<\/i>\s*Renew\s*<\/button>/s);
    $mech->content_contains( "___test_subscription_main" );
    $mech->content_contains( "___test_subscription_upgrade" );
    $mech->content_contains( "___test_subscription_downgrade" );

    my $gateway_module = 'Chargemonk::Helpers::Gateways::' . ucfirst($gateway);
    my $active_gateway = $gateway_module->new(
        args => {
            c                         => $mech->_app,
            link_user_subscription_id => $test_user_link_subscription->id,
            gateway_credentials       => $gateway_config->[0]->{gateways}->{$gateway}
        }
    );
    
    $active_gateway->delete_user();
    
    $test_user->delete;
}

$gateway_config->[0]->{default} = $original_gateway;
$gateway_config->write('conf/gateway.yaml');
