use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->get("/admin/users");
$mech->title_is("Chargemonk");

my $new_user_data = {
    email    => "new_user_public_links\@emailcom",
    password => "password",
    user_type=> "ADMIN"
};
my $new_user = $mech->_app->model("Chargemonk::User")->create($new_user_data);

$mech->post_ok( '/login', {email => $new_user_data->{email}, password => $new_user_data->{password}}, "Valid login" );
$mech->content_contains("Dashboard");

$mech->get("/logout");
$mech->title_is("Chargemonk");

$new_user->delete();
