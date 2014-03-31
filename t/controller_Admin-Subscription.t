use strict;
use warnings;

use Data::Dumper;
use DateTime;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::HTML::Form;
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;


my $uri = '/admin/subscriptions';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->post_ok( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$mech->get_ok($uri);

# we are on the admin page now, yoohoo
$mech->base_like(qr/$uri/);

$mech->get_ok("$uri/add_subscription");


######## Test Scenarios ############

### Scenario 1 #######
# Add a test group
# Add 3 subscriptions to the group: downgrade, main and upgrade
# Add 10 features
# Put all the features on the upgrade subscription, using the selected_features flag, as they are all selected from the interface
# Put all the features on the main subscription using import_features_from_subscr flag

my $group = $mech->_app->model('Chargemonk::SubscriptionGroup')->search( {name => '__test'} )->first();

my $test_subscription_data = {
    name                    => '___test_subscription_downgrade',
    subscription_type       => 'regular',
    subscription_group_id   => $group->id(),
    is_visible              => 0,
    require_company_data    => 0,
    has_auto_renew          => 1,
    access_type             => 'period',
    period                  => 2,
    period_unit             => 'Day',
    price                   => 10,
    currency                => 'EUR',
    number_of_users         => '',
    min_active_period_users => '',
    max_active_period_users => '',
    call_to_action          => 'Subscribe!',
    has_trial               => 0,
    require_credit_card     => 1,
    selected_group_order    => ['...+(this subscription)'],
    add_this_subscription   => 1,
    edit_this_subscription  => 1,
};
$mech->post_ok( "$uri/save", $test_subscription_data, 'Add ___test_subscription_downgrade' );
my $downgrade_subscription =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();

$mech->content_contains("The subscription '$test_subscription_data->{name}' was created");

# Some html content checking
my $form_values = Test::HTML::Form->get_form_values( {filename => $mech->{res}, form_name => 'add_subscription_form'} );
ok( $form_values->{subscription_type}->[0]->as_text() eq 'Select Type ... RegularPromo',
    'Subscription type allows Regular and Promo' );
ok( $form_values->{access_type}->[0]->as_text() eq
        ' Select Access Type ...  Period  Period Users  Resources  IP Users  API calls ',
    'Access type allows Period  Period Users  Resources  IP Users  API calls'
);

# Check if edit page loads fine
$mech->get_ok( "$uri/update/" . $downgrade_subscription->id(), 'Edit page is loads fine' );

# Add 10 test features
for ( 0 .. 10 ) {
    $mech->post_ok(
        '/admin/features/add_feature',
        {   name        => '__test_feature_' . $_,
            description => '__test desc',
        },
        'Add feature'
    );
}
my $test_features = $mech->_app->model('Chargemonk::Feature')->search( {name => {'LIKE', '__test%'}} );


# Add another subscription to use for upgrade
$test_subscription_data->{name} = '___test_subscription_upgrade';

# Put all the created features on this subscription and set the order to be first
my $diff = {
    selected_features    => [map                        { $_->id() } $test_features->all()],
    selected_group_order => ['...+(this subscription)', '___test_subscription_downgrade'],
};
$mech->post_ok( "$uri/save", {%$test_subscription_data, %$diff}, 'Add ___test_subscription_downgrade' );
my $upgrade_subscription =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();

# Check the subscription order, should be above ___test_subscription_downgrade
$mech->get_ok( "$uri/subscription_details/" . $upgrade_subscription->id(), 'Subscription details page' );
$mech->content_like( qr/id="group".*?___test_subscription_upgrade.*?___test_subscription_downgrade.*?id="upgrade"/s,
    'Subscriptions order looks good' );

# The number of features match in db
my @link_subscriptions_features =
    $mech->{_app}->model('Chargemonk::LinkSubscriptionFeature')->search( {subscription_id => $upgrade_subscription->id()} )
    ->all();
ok( scalar(@link_subscriptions_features) == scalar( $test_features->all() ), 'DB Test - number of features match' );


# Add the main subscription
$test_subscription_data->{name} = '___test_subscription_main';
$mech->post_ok( "$uri/save", $test_subscription_data, 'Add ___test_subscription_main' );
my $main_subscription =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();

# Update the subscription to use all the features from the upgrade one
$diff = {import_features_from_subscr => $upgrade_subscription->id()};
$mech->post_ok(
    "$uri/update/" . $main_subscription->id(),
    {%$test_subscription_data, %$diff},
    'Edit ___test_subscription_main, import features from _upgrade'
);
$mech->content_contains('was updated');


# Retrieve the features for db and check
@link_subscriptions_features =
    $mech->{_app}->model('Chargemonk::LinkSubscriptionFeature')->search( {subscription_id => $main_subscription->id()} )
    ->all();
ok( scalar(@link_subscriptions_features) == scalar( $test_features->all() ),
    'DB Test features added to the subscription by import from, on edit'
);

### END Scenario 1 #######


### Scenario 2 #######
#Add subscription:
#    Subscription name : ___test_subscription_s1
#    Subscription type : Promo
#    Subscription group : Test
#    Visibility : Admin only
#    Company Data? : No
#    Auto-renew? : No
#    Access : Period
#    Call to action : Subscribe to s1
#    Trial Period : 3
#    Trial Unit : Days
#    Trial Require credit card? : No
#    Trial Price : 0
#    Trial Price Unit : EUR
#Check if is visible from outside
#We add features
#We change visibility to public and check it's visible
#Start wizard on it, check no company data is required
#Set company data to Yes and check
#Set trial require credit card and check

$test_subscription_data = {
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
    trial_period            => 3,
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

$mech->get_ok('/logout');
$mech->get_ok('/pricing');
$mech->content_lacks('___test_subscription_s1');

$mech->post_ok( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );

$test_subscription_data->{'is_visible'} = 1;
$mech->post_ok( "$uri/update/" . $s1_subscription->id(),
    $test_subscription_data, 'Edit S1, set visibility to public' );
$mech->content_contains('was updated');
$mech->content_lacks('The subscription could not be updated');

$diff = {selected_features => [[$test_features->all()]->[0]->id()]};
$mech->post_ok(
    "$uri/update/" . $s1_subscription->id(),
    {%$test_subscription_data, %$diff},
    'Edit S1, add feature f0'
);
$mech->get_ok( "$uri/subscription_details/" . $s1_subscription->id() );
$mech->content_contains( '__test_feature_0', 'Feature f0 added successfully, seen on details page' );

$mech->get_ok('/logout');
$mech->get_ok('/pricing');
$mech->content_contains( '___test_subscription_s1', 'S1 shows on the pricing page' );

$mech->get_ok( '/register/subscription/' . $s1_subscription->id(), 'S1 registration page' );
$mech->content_lacks( 'Company information', 'S1 does not require company information' );

$mech->post_ok( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$diff = {require_company_data => 1};
$mech->post_ok(
    "$uri/update/" . $s1_subscription->id(),
    {%$test_subscription_data, %$diff},
    'Edit S1, required company info'
);
$mech->content_contains('was updated');
$mech->get_ok('/logout');
$mech->get_ok( '/register/subscription/' . $s1_subscription->id() );
$mech->content_contains( 'Company information', 'S1 requires company info' );

$mech->post_ok(
    '/register/step-1-confirmation/subscription/' . $s1_subscription->id,
    {   email            => '___test_email_s1',
        password         => '___test_email_s1',
        firstname        => '___test_email_s1',
        lastname         => '___test_email_s1',
        active_from_date => DateTime->now()->ymd(),
        active_to_date   => DateTime->now()->ymd(),
        terms            => 'on',
    },
    'Subscribe User'
);
$mech->content_contains('Please verify your email address');
my $s1_user = $mech->_app->model('Chargemonk::User')->search( {email => '___test_email_s1'} )->first();
my $token = $s1_user->search_related('user_registration_token')->first()->token();
ok( $s1_user && $token, 'User and token created successfully' );

$mech->get_ok("/activate_email/?token=$token");

# TODO: implement this functionality, the test crashes currently
#$mech->content_lacks('Card number');    # require_credit_card is set to 0 currently

### END Scenario 2 #######


### Scenario 3 #######
#Add subscription:
#    Subscription name : s2
#    Subscription type : Regular
#    Subscription group : Test
#    Visibility : Public
#    Company Data? : Yes
#    Auto-renew? : No
#    Access : Period Users
#    Number of concurent users From : 2
#    Number of concurent users To : 3
#    Call to action : Subscribe to s2
#    Period : 3
#    Unit : Days
#    Price : 10
#    Price Unit : EUR
#    Has Trial : NO
#    Features : f1
#    Group order : above s1
#    Downgrades to : s1
#Check if is visible
#Is asking company data
#Set trial to Yes, trial period 1 day, trial price 0 EUR
#    - check if db update is fine
#Add feature f2

$mech->post_ok( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$test_subscription_data = {
    name                    => '___test_subscription_s2',
    subscription_type       => 'regular',
    subscription_group_id   => $group->id(),
    is_visible              => 1,
    require_company_data    => 1,
    require_credit_card     => 0,
    has_auto_renew          => 0,
    access_type             => 'period_users',
    period                  => 30,
    period_unit             => 'Day',
    price                   => 10,
    currency                => 'EUR',
    number_of_users         => '',
    min_active_period_users => '2',
    max_active_period_users => '3',
    call_to_action          => 'Subscribe to s2',
    has_trial               => 0,
    selected_features       => [[$test_features->all()]->[1]->id()],
    selected_group_order    => ['...+(this subscription)', '___test_subscription_s1'],
    add_this_subscription   => 1,
    edit_this_subscription  => 1,
};
$mech->post_ok( "$uri/save", $test_subscription_data, 'Add S2' );
my $s2_subscription =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();

$mech->get_ok('/logout');
$mech->get_ok('/pricing');
$mech->content_contains( '___test_subscription_s2', 'S2 shows on the pricing page' );

$mech->get_ok( '/register/subscription/' . $s2_subscription->id() );
$mech->content_contains('Company information');

# Login again and change some data on the subscription
$mech->post_ok( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$diff = {
    has_trial         => 1,
    trial_period      => 3,
    trial_period_unit => 'Day',
    trial_price       => 0,
    trial_currency    => 'EUR',
};
$mech->post_ok(
    "$uri/update/" . $s2_subscription->id(),
    {%$test_subscription_data, %$diff},
    'Edit S2, set trial'
);
$mech->content_contains('was updated');

$s2_subscription =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();

my %db_data = map { $_ => $s2_subscription->$_() } keys %$diff;
ok( %$diff ~~ %db_data, 'Trial data successfully saved to db' );

$diff = {selected_features => [[$test_features->all()]->[2]->id()]};
$mech->post_ok(
    "$uri/update/" . $s2_subscription->id(),
    {%$test_subscription_data, %$diff},
    'Edit S2, add feature f2'
);
$mech->get_ok( "$uri/subscription_details/" . $s2_subscription->id() );
$mech->content_contains( '__test_feature_2', 'Feature 2 added successfully, seen on details page' );

### END Scenario 3 #######


### Scenario 4 #######
#Add subscription:
#    Subscription name : s3
#    Subscription type : Regular
#    Subscription group : Test
#    Visibility : Public
#    Company Data? : Yes
#    Auto-renew? : Yes
#    Access : IP Users
#    Number of concurent IPs From : 1
#    Number of concurent IPs To : 1
#    Call to action : Subscribe to s3
#    Period : 1
#    Unit : Month
#    Price : 100
#    Price Unit : EUR
#    Has Trial : Yes
#    Trial Period : 5
#    Trial Unit : Days
#    Trial Require credit card? : Yes
#    Trial Price : 0
#    Trial Price Unit : EUR
#    Features : Everithing on s2 + f7, f8
#    Group order : above s2
#    Downgrades to : s2
#Check if it's created ok
#Is visible and asking company data
#Update subscription to:
#    Resource quantity From : 2
#    Resource quantity To : 3
#    Visibility : Admin only
#Check is missing on the pricing page
#Edit subscription: replace features f7, f8 with f5, f6 and visibility to public
#Check the db save is fine
#Subscription appears on the pricing page


$mech->post_ok( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$test_subscription_data = {
    name                        => '___test_subscription_s3',
    subscription_type            => 'regular',
    subscription_group_id       => $group->id(),
    is_visible                  => 1,
    require_company_data        => 1,
    require_credit_card         => 0,
    has_auto_renew              => 1,
    access_type                 => 'IP_range',
    period                      => 30,
    period_unit                 => 'Day',
    price                       => 10,
    currency                    => 'EUR',
    number_of_users             => '',
    min_active_period_users     => '',
    max_active_period_users     => '',
    min_active_ips              => '1',
    max_active_ips              => '1',
    call_to_action              => 'Subscribe to s3',
    has_trial                   => 1,
    trial_period                => 5,
    trial_period_unit           => 'Day',
    trial_price                 => 0,
    trial_currency              => 'EUR',
    import_features_from_subscr => [$s2_subscription->id()],                                                 # f2
    selected_features           => [[$test_features->all()]->[7]->id(), [$test_features->all()]->[8]->id()], # f7 and f8
    selected_group_order   => ['___test_subscription_s2', '...+(this subscription)', '___test_subscription_s2'],
    selected_downgrades    => [$s2_subscription->id()],
    add_this_subscription  => 1,
    edit_this_subscription => 1,
};
$mech->post_ok( "$uri/save", $test_subscription_data, 'Add S3' );
$mech->content_contains("The subscription '$test_subscription_data->{name}' was created");
my $s3_subscription =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();

ok( defined $s3_subscription, 'S3 successfully add in db' );

@link_subscriptions_features =
    $mech->{_app}->model('Chargemonk::LinkSubscriptionFeature')->search( {subscription_id => $s3_subscription->id()} )
    ->all();
ok( scalar(@link_subscriptions_features) == 3, 'S3 has 3 features, one imported and two added' );

$mech->get_ok( "$uri/subscription_details/" . $s3_subscription->id() );
$mech->content_like( qr/id="features".*?__test_feature_2.*?__test_feature_7.*?__test_feature_8.*"/s,
    "S3 contains features: 2, 7, 8" );

$mech->content_like( qr/id="downgrade".*?___test_subscription_s2.*?<\/div>.*/s, 'S3 downgrades to S2' );

#warn $mech->content();

$mech->get_ok('/logout');
$mech->get_ok('/pricing');
$mech->content_contains( '___test_subscription_s3', 'S3 shows on the pricing page' );

$mech->get_ok( '/register/subscription/' . $s3_subscription->id() );
$mech->content_contains('Company information');

# Login again and change some data on the subscription
$mech->post_ok( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$diff = {
    is_visible            => 0,
    access_type           => 'resources',
    resource_type         => 'ips',
    min_resource_quantity => 2,
    max_resource_quantity => 3,
};
$mech->post_ok(
    "$uri/update/" . $s3_subscription->id(),
    {%$test_subscription_data, %$diff},
    'Edit S3, change visibility to admin and type to resources'
);
$mech->content_contains('was updated');

$mech->get_ok('/logout');
$mech->get_ok('/pricing');
$mech->content_lacks( '___test_subscription_s3', 'S3 does not show on the pricing page' );

$mech->post_ok( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );

$diff = {
    is_visible        => 1,
    selected_features => [map { [$test_features->all()]->[$_]->id() } ( '2', '5', '6' )],
};
$mech->post_ok(
    "$uri/update/" . $s3_subscription->id(),
    {%$test_subscription_data, %$diff},
    'Edit S3, change visibility to public and add features 2, 5, 6'
);
$mech->get_ok( "$uri/subscription_details/" . $s3_subscription->id() );
$mech->content_like( qr/id="features".*?__test_feature_2.*?__test_feature_5.*?__test_feature_6.*"/s,
    "S3 contains features: 2, 5, 6" );

### END Scenario 4 #######


### Scenario 5 #######
#Add subscription:
#    Subscription name : s4
#    Subscription type : Regular
#    Subscription group : Test
#    Visibility : Public
#    Company Data? : Yes
#    Auto-renew? : Yes
#    Access : API calls
#    Volume : 10000
#    Call to action : Subscribe to s4
#    Period : 1
#    Unit : Month
#    Price : 300
#    Price Unit : EUR
#    Has Trial : Yes
#    Trial Period : 5
#    Trial Unit : Days
#    Trial Require credit card? : Yes
#    Trial Price : 10
#    Trial Price Unit : EUR
#    Features : Everithing on s3 + f9
#    Group order : above s3
#    Downgrades to : s2, s3
#Check subscription added ok
#Upgrades to s3
#Check pricing: s3 and s4 shows up

$test_subscription_data = {
    name                        => '___test_subscription_s4',
    subscription_type           => 'regular',
    subscription_group_id       => $group->id(),
    is_visible                  => 1,
    require_company_data        => 1,
    require_credit_card         => 1,
    has_auto_renew              => 1,
    access_type                 => 'API_calls',
    api_calls_volume            => '10000',
    period                      => 1,
    period_unit                 => 'Month',
    price                       => 300,
    currency                    => 'EUR',
    number_of_users             => '',
    min_active_period_users     => '',
    max_active_period_users     => '',
    min_active_ips              => '1',
    max_active_ips              => '1',
    call_to_action              => 'Subscribe to s4',
    has_trial                   => 1,
    trial_period                => 5,
    trial_period_unit           => 'Day',
    trial_price                 => 10,
    trial_currency              => 'EUR',
    import_features_from_subscr => [$s3_subscription->id()],                # f2, f5, f6
    selected_features           => [[$test_features->all()]->[9]->id()],    # f9
    selected_group_order =>
        ['___test_subscription_s1', '___test_subscription_s2', '...+(this subscription)', '___test_subscription_s3'],
    add_this_subscription  => 1,
    edit_this_subscription => 1,
};
$mech->post_ok( "$uri/save", $test_subscription_data, 'Create S4' );
$mech->content_contains("The subscription '$test_subscription_data->{name}' was created");
my $s4_subscription =
    $mech->_app->model('Chargemonk::Subscription')->search( {name => $test_subscription_data->{name}} )->first();

ok( defined $s4_subscription, 'S4 successfully add in db' );

@link_subscriptions_features =
    $mech->{_app}->model('Chargemonk::LinkSubscriptionFeature')->search( {subscription_id => $s4_subscription->id()} )
    ->all();
ok( scalar(@link_subscriptions_features) == 4, 'S4 has 4 features, 3 imported and one added' );

$mech->get_ok( "$uri/subscription_details/" . $s4_subscription->id() );
$mech->content_like( qr/id="features".*?__test_feature_2.*?__test_feature_5.*?__test_feature_6.*?__test_feature_9.*"/s,
    "S4 contains features: 2, 5, 6, 9" );

$mech->get_ok('/logout');
$mech->get_ok('/pricing');

### END Scenario 5 #######

# The cleanup is done by the mechanize module