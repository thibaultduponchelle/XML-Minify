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

my $mininoblanks_start = << "EOM";
<person><name>Tib
Bob
Richard
</name><level/></person>
EOM

my $mininoblanks_end = << "EOM";
<person><name>
Tib
Bob
Richard</name><level/></person>
EOM

my $mininoblanks_both = << "EOM";
<person><name>Tib
Bob
Richard</name><level/></person>
EOM

chomp $mini;
chomp $mininoblanks_start;
chomp $mininoblanks_end;
chomp $mininoblanks_both;

is(minify($maxi, no_prolog => 1, remove_spaces_everywhere => 1), $mini, "Remove spaces everywhere");
is(minify($maxi, no_prolog => 1, remove_blanks_start => 1, remove_spaces_everywhere => 1), $mininoblanks_start, "Remove spaces everywhere with no blanks (1 remove_blanks_start)");
is(minify($maxi, no_prolog => 1, remove_blanks_end => 1, remove_spaces_everywhere => 1), $mininoblanks_end, "Remove spaces everywhere with not blanks (2 use remove_blanks_end)");
is(minify($maxi, no_prolog => 1, remove_blanks_start => 1, remove_blanks_end => 1, remove_spaces_everywhere => 1), $mininoblanks_both, "Remove spaces everywhere with no blanks (3 use both)");

ok(1);

done_testing;

