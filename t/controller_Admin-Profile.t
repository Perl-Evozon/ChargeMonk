use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;


my $uri = '/admin/profile';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->post( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$mech->get_ok($uri);

# we are on the admin page now, yoohoo
$mech->base_like(qr/$uri/);

# / gets to dashboard
$mech->content_like(qr/<i class=\"icon icon-edit\"><\/i>\s*Edit profile\s*<\/button>/s);