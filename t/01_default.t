use strict;
use warnings;

use Test::More 0.98;

use XML::Minify "minify";

my $maxi = "<empty></empty>";
my $mini = "<empty/>";
is(minify($maxi, no_prolog => 1), $mini, "Merge tags");


$maxi = "<empty   />";
$mini = "<empty/>";
is(minify($maxi, no_prolog => 1), $mini, "Drop spaces (1)");

$maxi = "        <empty />           ";
$mini = "<empty/>";
is(minify($maxi, no_prolog => 1), $mini, "Drop spaces (2)");

$maxi = "<empty       ></empty        >";
$mini = "<empty/>";
is(minify($maxi, no_prolog => 1), $mini, "Merge tags and drop spaces");

done_testing;

