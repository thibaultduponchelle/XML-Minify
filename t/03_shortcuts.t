use strict;
use warnings;

use Test::More 0.98;

use XML::Minify "minify";

my $maxi = << "EOM";

<person


>
  <name  >
    Tib
    Bob
    Richard
  </name   
  >
  <level  > 


</level          >
</person   >




EOM

my $mini = << "EOM";
<person><name>Tib    Bob    Richard</name><level/></person>
EOM

chomp $mini;

# Agressive mode (despite being lossy compression) is what I'm proud of because it removes what humans generally consider as extra sugar
is(minify($maxi, no_prolog => 1, agressive => 1), $mini, "Agressive");


ok(1);

done_testing;

