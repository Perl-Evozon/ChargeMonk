#!/usr/bin/env perl

use 5.10.1;

use strict;
use warnings;

use Data::Dumper;
use DateTime;
use FindBin;
use lib "$FindBin::Bin/../lib";
use utf8;
use Try::Tiny;

use Chargemonk;

my $c = Chargemonk->new;

try {
    $c->model('Chargemonk')->schema->storage->dbh_do(
        sub {
            my ( $storage, $dbh, @args ) = @_;
            $dbh->do("DROP DATABASE IF EXISTS ".Chargemonk->config->{tests_db})
                ;    # drop and create cannon be run within a single sql command, in psql
            $dbh->do("CREATE DATABASE ".Chargemonk->config->{tests_db});
        },
    );
}
catch {
    warn "Error creating test database: $_";
};

# deploy the schema to the tests db

my $conn_info = $c->model('Chargemonk')->schema->storage->_connect_info->[0];
$conn_info->{dsn} =~ s/database=(.*);/"database=".Chargemonk->config->{tests_db}.";"/ge;

my $test_schema = Chargemonk::Schema->connect($conn_info);
$test_schema->deploy({ add_drop_table => 1 });
$c->model('Chargemonk')->schema($test_schema);



exit;

=head1 NAME

init_database.pl - Create database schema based on models

=head1 SYNOPSIS

perl ./scripts/init_database.pl

=cut
