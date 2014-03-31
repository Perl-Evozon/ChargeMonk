use strict;
use warnings;

use Chargemonk;

my $app = Chargemonk->apply_default_middlewares(Chargemonk->psgi_app);
$app;

