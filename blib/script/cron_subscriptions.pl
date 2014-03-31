#!/usr/bin/env perl

=head1 NAME

cron_subscriptions.pl

=head1 SYNOPSIS

Run over the running link subscriptions and detect the ones that need to be taken care of:
    - the ones that are about to expire, one day before expiring(configurable in the module)
    -  the ones expired
=cut

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use SubMan;
use SubMan::Helpers::Cron::Subscriptions;

my $cron = SubMan::Helpers::Cron::Subscriptions->new();

$cron->run();

print "done\n";