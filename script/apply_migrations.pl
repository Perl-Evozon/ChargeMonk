#!/usr/bin/env perl

use 5.10.1;

use strict;
use warnings;

use DateTime;
use File::Slurp;
use FindBin;
use lib "$FindBin::Bin/../lib";
use utf8;

use Chargemonk;

my $c              = Chargemonk->new;
my $migrations_dir = "$FindBin::Bin/../sql/";

print "\nApplying SQL migrations\n";
print "-------------------------\n";

my $last_run_obj = $c->model("Chargemonk::Config")->find('last_migration_run');
my $first_time   = 0;
if ( !$last_run_obj ) {    # first run
    $first_time = 1;

    #add the entry in the config table
    $last_run_obj = $c->model("Chargemonk::Config")->create(
        {   key   => 'last_migration_run',
            value => DateTime->now(),
        }
    );
}

my $dbh = $c->model('Chargemonk')->storage->dbh;

my @sql_files = read_dir $migrations_dir;

for my $file (@sql_files) {
    if ( $file =~ /(\d{4}-\d{2}-\d{2}T.*?)_/ ) {
        if ( $first_time || $1 gt $last_run_obj->value() ) {
            print "\napplying migration $file";

            open(SQL, "$migrations_dir/$file");
            local $/ = ';'; 
            while ( my $sql_statement = <SQL> ) {
                warn "\n\t$sql_statement";
                eval {
                    $dbh->do($sql_statement);
                };
                warn $@ if ($@);
            }
        }
    }
}


$last_run_obj->update({ "value" => DateTime->now() });

print "\nDone\n";

exit;

=head1 NAME

chargemonk_create_admin.pl - Apply SQL migrations for the project

=head1 SYNOPSIS

perl ./scripts/apply_migrations.pl

=cut
