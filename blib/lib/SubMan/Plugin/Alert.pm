package SubMan::Plugin::Alert;

=head1 NAME

SubMan::Plugin::Alert- Catalyst Alert Plugin

=head1 DESCRIPTION

Pushes an hash into the $c->stash->{alerts}.

=head1 METHODS

=cut


=head2 alert 

    Pushes the alert hash into the $c->stash->{alerts}.
    Most of the times we push a message to the stash but we also log the same message in the error log
    Now we can do it easily within one function
    Check the alert type for success/error to log info or error messages
        - expect the error as param, if error alert

=cut


sub alert {
    my ($c, $alert, $extra) = @_;

    if ($alert->{error}) {
        $c->logger->error( $alert->{error} . " : $extra" );
    } elsif(my $msg = ($alert->{success} || $alert->{info})) {
        $c->logger->info( $msg. " $extra" );
    }
    
    push @{$c->stash->{alerts}}, $alert;
}

sub has_errors {
    my ($c) = @_;

    return grep { defined $_->{error} } @{$c->stash->{alerts}} ? 1 : 0;
}

1;
