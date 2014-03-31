package Chargemonk::View::JSON;
use base qw( Catalyst::View::JSON );

use JSON qw();

#create a class variable that we will use to encode the json responses
my $encoder = JSON->new->utf8(1)->pretty(0);

=head
    Encodes the stash data and sends it along
    note: $data->{encode_response_data} signals that the encoder should
    process $data->{response_data} instead of $data.
    This is done because the old(imported) actions put all of their stash data
    in $c->stash->{response_data}
=cut
sub encode_json {
    my($self, $c, $data) = @_;

    if( $data->{encode_response_data} && $data->{encode_response_data} == 1 ){
        $encoder->encode( $data->{response_data} );
    } else {
        $encoder->encode( $data );
    }

}

1;