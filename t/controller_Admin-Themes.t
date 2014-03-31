use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More qw(no_plan);

use Chargemonk::Test::Mechanize;

my $uri = '/admin/themes';

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->post( '/login', { email => '___test_admin', password => '___test_admin' }, 'Valid login' );
$mech->get_ok($uri);

# we are on the admin page now, yoohoo
$mech->base_like(qr/$uri/);

# the page contaings the Default theme
$mech->content_like( qr/src="\/static\/themes\/default\/Default\.jpg"/s,
    "has default theme" );
my $initial_active_theme = $mech->_app->model('Chargemonk::Theme')->search({ active      => 1 })->single;

###
#   Step 1
#   add a theme and make it default
###
my $css_path =
  $mech->_app->path_to( 'root', 'static', 'test_themes', 'test_style.css' );

my $css_file = [
    $css_path => $css_path,          #The file you'd like to upload. and The filename you'd like to give the web server
    'Content-type' => 'text/plain'   # Any other flags you'd like to add go here.
];

$mech->post(
    $uri."/add_theme",
    'Content_Type' => 'form-data',
    'Content'      => {
  # this will only give an <<Image corrupt or truncated: >> error in the browser
  # we do not need a readable image for testing
        'photo_input' => "AAAAAAAAAAAAAAAAAAAAABBBBBCCCCCCCCC",
        'name'        => 'test_template',
        'css_file'    => $css_file,
        'active'      => 1,
    }
);

my $new_theme = $mech->_app->model('Chargemonk::Theme')->search(
    {
        active      => 1,
        name        => 'test_template',
    }
)->single;

ok( defined $new_theme , "test theme added to the database" );
$mech->content_contains("The theme \'".$new_theme->name."\' was created");

$mech->get_ok($uri);

my $regexp = '<input type="checkbox" name="theme_id" value='.$new_theme->id.' checked';
$mech->content_like( qr/$regexp/s, "has new test theme and the theme is checked" );
$mech->content_like(qr/href="\/static\/themes\/(.*)\/style.css" rel="stylesheet"/s, 'The css is included in the page');

###
#   Step 2
#   deactivate the test theme and activate the default theme
###

$mech->post_ok($uri.'/activate', { theme_id => 1 }, 'Activate default theme');
$regexp = '<input type="checkbox" name="theme_id" value=1 checked';
$mech->content_like( qr/$regexp/s, "has default theme and the default theme is checked" );
$mech->content_unlike(qr/href="\/static\/themes\/(.*)\/style.css" rel="stylesheet"/s, 'The css is not included in the page');

###
#   Step 3
#   delete the test theme
###

$regexp = '<input type="checkbox" name="theme_id" value='.$new_theme->id.' checked';
$mech->get_ok($uri.'/delete_theme/'.$new_theme->id, ' deleting new test theme');
$mech->content_unlike( qr/$regexp/s, "has new test theme is not on the page" );
$mech->content_unlike(qr/href="\/static\/themes\/(.*)\/style.css" rel="stylesheet"/s, 'The css is not included in the page.');

###
#   Step 4
#   reactivate initial theme 
###
if ($initial_active_theme) {
    $regexp = '<input type="checkbox" name="theme_id" value='.$initial_active_theme->id.' checked';
    $mech->post_ok($uri.'/activate', { theme_id => $initial_active_theme->id }, 'Activate initial theme.');
    $mech->content_like( qr/$regexp/s, "has initial theme and the default theme is checked." );
} else {
    $mech->_app->model('Chargemonk::Theme')->search( {} )->update({ active => 0 });
}

$mech->get_ok('/logout');
