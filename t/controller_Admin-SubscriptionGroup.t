use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;


my $uri = '/admin/subscriptions';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->post( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );

# Create group
$mech->post_ok( $uri, {name => '__test', create_this_group => 1}, 'Add group' );
my $group = $mech->_app->model('Chargemonk::SubscriptionGroup')->search( {name => '__test'} )->first();

# Edit group
$mech->post_ok( $uri, {id => $group->id(), name => '__test_edited', edit_this_group => 1}, 'Edit group' );
$group = $mech->_app->model('Chargemonk::SubscriptionGroup')->find( $group->id() );
ok( $group->name() eq '__test_edited', 'Group name changed in db' );

# delete group
$mech->post_ok( $uri, {id => $group->id(), delete_this_group => 1}, 'Delete group' );


# TODO: Add subscription to group, delete not possible anymore

