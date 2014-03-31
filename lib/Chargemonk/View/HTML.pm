package Chargemonk::View::HTML;

use Moose;
use Chargemonk;
use namespace::autoclean;
use Chargemonk;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
    INCLUDE_PATH => [Chargemonk->path_to('root').'/templates/'],
    PRE_CHOMP  => 2,
    POST_CHOMP => 2
);

=head1 NAME

Chargemonk::View::HTML - TT View for Chargemonk

=head1 DESCRIPTION

TT View for Chargemonk.

=head1 SEE ALSO

L<Chargemonk>

=head1 AUTHOR

natasha

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
