use strict;
use warnings;

use Test::More 0.98;

use XML::Minify qw(minify);

my $maxicommented = << "END";
<root>  <!-- Comment -->
  <!-- Comment -->  <tag></tag>
</root>
END

my $minicommented = << "END";
<root>  <!-- Comment -->
  <!-- Comment -->  <tag/></root>
END

my $miniuncommented = << "END";
<root><tag/></root>
END



chomp $maxicommented;
chomp $minicommented;
chomp $miniuncommented;

is(minify($maxicommented, no_prolog => 1, keep_comments => 1), $minicommented, "Keep comments");
is(minify($maxicommented, no_prolog => 1, keep_comments => 0), $miniuncommented, "Explicitely remove comments");

done_testing;

