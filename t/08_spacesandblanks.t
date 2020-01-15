use strict;
use warnings;

use Test::More 0.98;

use XML::Minify "minify";

my $maxi = << "EOM";

<person>
  <name>
    T i b   
    B    o b
    R  i    c h  a r d
  </name   
  >
  <level  >
</level          >
</person   >




EOM

my $mini = << "EOM";
<person>
<name>
Tib
Bob
Richard
</name>
<level>
</level>
</person>
EOM

chomp $mini;

is(minify($maxi, no_prolog => 1, remove_spaces_everywhere => 1), $mini, "Remove spaces everywhere");

ok(1);

done_testing;

