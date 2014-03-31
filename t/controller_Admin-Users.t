use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;


my $uri = '/admin/users';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->post( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$mech->get_ok($uri);

# we are on the admin page now, yoohoo
$mech->base_like(qr/$uri/);


## Specific tests for the users page
#   Add user
#   Check it appears in the table with the data entered
#   Filters work

$mech->get_ok("$uri/add_user");

my $test_user_hash = {
    gender    => 'M',
    firstname => 'John',
    lastname  => 'P',
    email     => 'johnp@email.com',
    birthday  => '1971-04-15',
    address   => 'some address',
    address2  => 'some address 2',
    country   => 'Romania',
};

# Post standard user
$mech->post( "$uri/create_user", $test_user_hash );

$mech->content_contains('The user was successfuly created');

# try to search if all the data saved is in the table
my $user = $mech->_app->model('Chargemonk::User')->search($test_user_hash)->first();

# Find the user in the html table
$mech->get_ok($uri);
$mech->content_contains( $test_user_hash->{email} );

# is LEAD
ok( $user->user_type eq 'LEAD', 'Is LEAD' );

# Check user_details
$mech->get_ok( "$uri/user_details/" . $user->id );
$mech->content_contains( $test_user_hash->{email} );
$mech->content_contains( $test_user_hash->{firstname} . ' ' . $test_user_hash->{lastname} );

# get edit_user page
$mech->get_ok( "$uri/edit_user/" . $user->id );

my $test_user_hash_updated = {
    gender    => 'F',
    firstname => 'Steve',
    lastname  => 'S',
    birthday  => '1972-10-10',
    address   => 'some address changed',
    address2  => 'some address changed 2',
    country   => 'Somalia',
    email     => $user->email(),
    id        => $user->id
};

# Edit the user
$mech->post( "$uri/save_user/" . $user->id, $test_user_hash_updated );
$mech->content_contains('The user was successfuly edited');

my $user_updated = $mech->_app->model('Chargemonk::User')->search($test_user_hash_updated)->first();

# set user password
my $user_token = $mech->_app->model('Chargemonk::UserPswSetToken')->find( $user_updated->id );

# the token should always invalid as it is longer then maximum length
$mech->get_ok( "/set_user_password?token=" . $user_token->token . "s" );
$mech->content_contains('Token is no longer valid');

$mech->get_ok( "/set_user_password?token=" . $user_token->token );

$mech->content_contains(
    'Set User Password for ' . $test_user_hash_updated->{firstname} . ' ' . $test_user_hash_updated->{lastname} );

my $testing_scenarios = {
    1 => {
        post => {
            get_password => 'pass1',
            re_password  => 'pass2',
        },
        message => 'Passwords do not match'
    },
    2 => {
        post => {
            get_password => 'pass1',
            re_password  => '',
        },
        message => 'Re-type password field should not be empty'
    },
    3 => {
        post => {
            get_password => '',
            re_password  => 'pass2',
        },
        message => 'Password field should not be empty'
    },
    4 => {
        post => {
            get_password => 'pass1',
            re_password  => 'pass1',
        },
        message => 'Your password was set successfully'
    },
};

foreach my $case ( sort keys %{$testing_scenarios} ) {
    $mech->post(
        "/set_user_password?token=" . $user_token->token,
        $testing_scenarios->{$case}->{post},
        $testing_scenarios->{$case}->{message}
    );
    $mech->content_contains( $testing_scenarios->{$case}->{message} );
}

# forgot password
$mech->post('/logout');

$uri = '/forgot_password';
$mech->get_ok($uri);
$mech->content_contains('Please provide email address');

$mech->post( $uri, {email => $user_updated->email} );
$mech->content_contains('An email was sent to help with setting');

$user_token = $mech->_app->model('Chargemonk::UserPswSetToken')->find( $user_updated->id );
ok( $user_token, 'Token found in database' );

# Cleanup
# remove the added users
$user->delete();


