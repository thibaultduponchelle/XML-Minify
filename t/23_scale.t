use strict;
use warnings;

use Test::More 0.98;

use XML::Minify "minify";

# At the time I write this test, we scale badly 
# (probably due to the siblings checks)
for (my $n = 10; $n <= 100000; $n *= 10) {
	my $maxi = "<root> \n \n \n";
	$maxi .= "<tag></tag>" x $n;
	$maxi .= "\n \n \n </root>";


	my $mini = "<root>";
	$mini .= "<tag/>" x $n;
	$mini .= "</root>";

	is(minify($maxi, no_prolog => 1), $mini, "Scale $n");
}

done_testing;

