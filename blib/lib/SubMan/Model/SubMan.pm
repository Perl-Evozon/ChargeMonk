package SubMan::Model::SubMan;

use strict;
use SubMan;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'SubMan::Schema',
    connect_info => SubMan->config->{db_engine} eq 'pg'
    ? { dsn         => 'dbi:Pg:dbname=' . SubMan->config->{pg_dbname} . ';host=' . SubMan->config->{pg_host},
        user        => SubMan->config->{pg_user},
        password    => SubMan->config->{pg_password},
        quote_names => 1,
        }
    : SubMan->config->{db_engine} eq 'mysql' ? {
        dsn         => 'DBI:mysql:database=' . SubMan->config->{mysql_dbname} . ';host=' . SubMan->config->{mysql_host},
        user        => SubMan->config->{mysql_user},
        password    => SubMan->config->{mysql_password},
        quote_names => 1,
        }
    : {},
);

=head1 NAME

SubMan::Model::SubMan - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<SubMan>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<SubMan::Schema>

=head1 GENERATED BY

Catalyst::Helper::Model::DBIC::Schema - 0.6

=head1 AUTHOR

dev

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
