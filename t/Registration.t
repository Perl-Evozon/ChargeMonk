use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;
use Chargemonk::Test::Register;

use DateTime;

my $uri = '/';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->get_ok($uri);
$mech->base_like(qr{.*index.html});    # not logged in, redirected to the home page

$mech->get_ok('/pricing');

my $register_corporate = Chargemonk::Test::Register->new( mech => $mech );

$register_corporate->run_registration();
