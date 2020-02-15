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

my $minikeepcrlf = << "EOM";
<person><name>Tib
    Bob
    Richard</name><level/></person>
EOM


chomp $mini;
chomp $minikeepcrlf;

# Agressive mode (despite being lossy compression) is what I'm proud of because it removes what humans generally consider as extra sugar
is(minify($maxi, no_prolog => 1, agressive => 1), $mini, "Agressive");

is(minify($maxi, no_prolog => 1, agressive => 1, remove_cr_lf_everywhere => 0), $minikeepcrlf, "Agressive but keep CR LF (1)");
is(minify($maxi, no_prolog => 1, remove_cr_lf_everywhere => 0, agressive => 1), $minikeepcrlf, "Agressive but keep CR LF (2 change order)");

done_testing;

