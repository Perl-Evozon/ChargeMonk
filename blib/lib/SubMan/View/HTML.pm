package SubMan::View::HTML;

use Moose;
use SubMan;
use namespace::autoclean;
use SubMan;

extends 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
    INCLUDE_PATH => [SubMan->path_to('root').'/templates/'],
    PRE_CHOMP  => 2,
    POST_CHOMP => 2
);

=head1 NAME

SubMan::View::HTML - TT View for SubMan

=head1 DESCRIPTION

TT View for SubMan.

=head1 SEE ALSO

L<SubMan>

=head1 AUTHOR

natasha

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
