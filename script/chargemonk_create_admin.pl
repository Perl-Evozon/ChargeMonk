#!/usr/bin/env perl

use 5.10.1;
use strict;
use warnings;
use utf8;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Term::ReadKey;
use Chargemonk;

my $c = Chargemonk->new;

print "\nCreate a new administrator account for Chargemonk\n";
print "---------------------------------------------\n";

ATTEMPT: while (1) {
    print 'Enter your email for login: ';
    my $email = <>;
    chomp $email;
    if ( $c->model('Chargemonk::User')->search( { email => $email } )->all ) {
        print "Email already used! Please try again\n\n";
        next ATTEMPT;
    }

    ReadMode(2);

    print 'Enter your password: ';
    my $password = <>;
    chomp $password;
    print "\n";

    print "Re-type your password: ";
    my $password_retry = <>;
    chomp $password_retry;
    print "\n\n";

    ReadMode(0);

    if ( $password ne $password_retry ) {
        print "Passwords don't match! Try again\n\n";
        next ATTEMPT;
    }
    else {
        eval {
            $c->model('Chargemonk::User')->create(
                {
                    email    => $email,
                    password => $password,
                    user_type=> 'ADMIN',
                }
            );
        };
        if ($@) {
            say 'Problem creating user account!';
        }
        else {
            say 'User account created.';
        }

        last ATTEMPT;
    }
}

exit;

=head1 NAME

chargemonk_create_admin.pl - Create a new administrator account for Chargemonk

=head1 SYNOPSIS

perl ./scripts/chargemonk_create_admin.pl

=cut
