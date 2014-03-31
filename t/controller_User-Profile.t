use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;


my $uri = '/user/profile';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->post( '/login', {email => '___test_user', password => '___test_user'}, 'Valid login' );
$mech->get_ok($uri);

# we are on the profile page 
$mech->base_like(qr/$uri/);

$mech->content_like(qr/<i class=\"icon icon-edit\"><\/i>\s*Edit profile\s*<\/button>/s);

my $test_user_hash = {
    gender    => 'M',
    firstname => 'John',
    lastname  => 'Doe',
    birthday  => '1980-10-10',
    address   => 'some address',
    address2  => 'some address 2',
    country   => 'Romania',
};

# Edit the user profile 
$mech->post( "$uri/edit_profile/", $test_user_hash);
$mech->content_contains('The user was successfuly edited');

my $user = $mech->_app->model('Chargemonk::User')->search( $test_user_hash )->first();

#test is profile page has the changed user data
$mech->get_ok($uri);
$mech->content_contains( '<h1> '.$user->firstname().' '.$user->lastname().' </h1>' );

