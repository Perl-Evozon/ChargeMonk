package Chargemonk::Helpers::Common::DateTime;

use DateTime;

use Chargemonk::Common::Logger qw($logger);

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(convert_to_days timestamp timestamp_daystart timestamp_dayend);
our @EXPORT    = qw(convert_to_days timestamp timestamp_daystart timestamp_dayend);

our %date_units = (
    day   => 1,
    week  => 7,
    month => 30,
    year  => 365,
);

=head1 NAME

Chargemonk::Helpers::Common::DateTime- Common Helper for Chargemonk

=head1 DESCRIPTION

Chargemonk helpers for DateTime conversions.

=head1 METHODS

=cut


=head2 convert_to_days

    Helper for converting periods of time in number of days

=cut

sub convert_to_days {
    my ( $count, $unit ) = @_;

    my $days      = 0;
    my $converted = 0;

    foreach ( keys(%date_units) ) {
        if ( $unit =~ /$_/i ) {
            $days      = $count * $date_units{$_};
            $converted = 1;
            last;
        }
    }

    unless ($converted) {
        $logger->fatal("Period conversion to 'days' failed for count '$count' and unit '$unit'.");
    }

    return $days;
}


=head2 timestamp

Return the common timestamp

=cut

sub timestamp {
    my $dt = shift;

    return unless $dt;

    return $dt->ymd . ' ' . $dt->hms;
}


=head2 timestamp_daystart

Return the timestamp with the hms set to 00:00:00

=cut


sub timestamp_daystart {
    my $dt = shift;

    return unless $dt;

    return $dt->ymd . ' 00:00:00';
}

=head2 timestamp_daystart

Return the timestamp with the hms set to 00:00:00

=cut

sub timestamp_dayend {
    my $dt = shift;

    return unless $dt;

    return $dt->ymd . ' 23:59:59';
}

1;
