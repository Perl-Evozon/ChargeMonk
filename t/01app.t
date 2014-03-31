#!/usr/bin/env perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Chargemonk::Test::Mechanize;
use Test::More tests => 1;

my $mech = Chargemonk::Test::Mechanize->new( catalyst_app => 'Chargemonk' );

$mech->get_ok('/');

