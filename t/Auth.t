use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;


my $uri = '/admin/users';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->get_ok($uri);

$mech->base_like(qr{.*index.html});    # not logged in, redirected to the home page

$mech->post( '/login', {email => '___test_admin', password => 'dummy'}, 'Invalid login' );
$mech->content_contains("Username/password don't match");

$mech->post( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$mech->get_ok($uri);

$mech->get_ok("$uri/add_user");
my $test_user_hash = {
    gender    => 'M',
    firstname => 'John',
    lastname  => 'P',
    email     => '___test_email_auth1@domain.com',
    birthday  => 'April 15, 1971',
    address   => 'some address',
    address2  => 'some address 2',
    country   => 'Romania',
};

# Post standard user
$mech->post( "$uri/create_user", $test_user_hash );

$mech->content_contains('The user was successfuly created');
my $user = $mech->_app->model('Chargemonk::User')->search( {email => $test_user_hash->{email}} )->first();

# Activating standard user
#  get token first
my $token = $user->search_related('user_psw_set_token')->first->token();
$mech->get_ok("/set_user_password?token=$token");

$mech->post_ok(
    '/set_user_password',
    {   token        => $token,
        get_password => 'temp12',
        re_password  => 'temp12',
    }
);
$mech->content_contains('Your password was set successfully');

# Login user
$mech->post( '/login', {email => $test_user_hash->{email}, password => 'dummy'} );
$mech->content_contains("Username/password don't match");

$mech->post_ok( '/login', {email => $test_user_hash->{email}, password => 'temp12'} );
$mech->content_contains("/logout");

$mech->get('/logout');

# Make it admin user
$user->user_type('ADMIN');
$mech->post_ok( '/login', {email => $test_user_hash->{email}, password => 'temp12'} );
$mech->get_ok($uri);

# Try to create user with the same address
$mech->post( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$mech->post_ok( "$uri/create_user", $test_user_hash, 'Add the same user again' );
$mech->content_contains('Email already registered');
#warn $mech->content();
$mech->get('/logout');


# Cleanup
# remove the added users
$user->delete();
