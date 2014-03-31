use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;


my $uri = '/admin/registration';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->post( '/login', {email => '___test_admin', password => '___test_admin'}, 'Valid login' );
$mech->get_ok($uri);

# we are on the admin page now, yoohoo
$mech->base_like(qr/$uri/);

# Change the required fields for registration
$mech->post(
    $uri,
    {   first_name   => 1,
        last_name    => 1,
        company_name => 1
    }
);

$mech->content_like(qr/name="sex"\s\/>.*name="first_name"\schecked.*name="last_name"\schecked/s);
