use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More skip_all => 'page deactivated at the moment';

use Chargemonk::Test::Mechanize;


my $uri = '/dashboard';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->post( '/login', {email => '___test_user', password => '___test_user'}, 'Valid login' );
$mech->get_ok($uri);

# we are on the admin page now, yoohoo
$mech->base_like(qr/$uri/);