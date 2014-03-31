use strict;
use warnings;

use SubMan;

my $app = SubMan->apply_default_middlewares(SubMan->psgi_app);
$app;

