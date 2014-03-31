package Chargemonk::Common::Logger;

use strict;
use warnings;

use base qw( Exporter );
our @EXPORT = qw($logger);

use File::Basename;
use File::Path qw(make_path);
use Log::Log4perl qw(get_logger);

=head1 NAME

Chargemonk::Common::Logger - Logger Tool for Chargemonk

=head1 DESCRIPTION

Initializes Log4perl and dispatches log messages for Chargemonk.

=head1 METHODS

=cut


# create paths for logger files, if they don't exist
BEGIN {
    my $log_conf_file = dirname(__FILE__)."/../../../conf/log4perl.conf";

    open( my $fh, "<", $log_conf_file );
    foreach my $line (<$fh>) {
        if ( $line =~ /appender/i && $line =~ /filename/i and $line =~ /=\s*(.+?)\s*$/ ) {
            my $file = $1;
            my $dir  = dirname($file);
            eval { make_path($dir); } if ( not -d $dir );
            eval { open( my $file, '>', $file ); close $file; } if ( not -e $file );
        }
    }
    close($fh);

    # load Log4perl Logger
    Log::Log4perl->init($log_conf_file);
}

our $logger = Chargemonk::Common::Logger->new();

my $logger_error = get_logger('error');
my $logger_info  = get_logger('info');

=head2 new

Constructor for Chargemonk::Common::Logger

=cut

sub new {
    my ( $class, %args ) = @_;
    return bless {%args}, $class;
}

=head2 warn

Handler for 'warning' messages.

=cut

sub warn {
    my ( $self, $msg ) = @_;
    $logger_error->warn($msg);
}

=head2 error

Handler for 'error' messages.

=cut

sub error {
    my ( $self, $msg ) = @_;
    $logger_error->error($msg);
}

=head2 fatal

Handler for 'fatal' messages.

=cut

sub fatal {
    my ( $self, $msg ) = @_;
    $logger_error->fatal($msg);
}

=head2 info

Handler for 'info' messages.

=cut

sub info {
    my ( $self, $msg ) = @_;
    $logger_info->info($msg);
}

=head2 debug

Handler for 'debug' messages.

=cut

sub debug {
    my ( $self, $msg ) = @_;
    $logger_info->debug($msg);
}

1;
