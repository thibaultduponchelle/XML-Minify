use strict;
use warnings;

use Test::More 0.98;

use XML::Minify qw(minify);


# Actually we test that the processing of entities which is a feature implemeted by xmlprocessor (XML::LibXML) is preserved by our minifier


my $maxi = << "END";
<root>

  <keepblanks>



  </keepblanks>

</root>
END

my $minikeepblanks = << "END"; 
<root><keepblanks>



  </keepblanks></root>
END

chomp $maxi;
chomp $minikeepblanks;

#is(minify($maxi, no_prolog => 1), $minikeepblanks, "Keep blanks in text nodes where parent has only one child (1)");

$maxi = << "END";
<root>

Not empty

  <keepblanks>



  </keepblanks>

Not empty

</root>
END

$minikeepblanks = << "END"; 
<root>

Not empty

  <keepblanks>



  </keepblanks>

Not empty

</root>
END


chomp $maxi;
chomp $minikeepblanks;

#is(minify($maxi, no_prolog => 1), $minikeepblanks, "Keep blanks in text nodes where parent has only multiple child nodes but not empty (1)");

$maxi = << "END";
<root>

<!-- Comment -->

  <keepblanks>



  </keepblanks>

<!-- Comment -->

</root>
END

$minikeepblanks = << "END"; 
<root>

<!-- Comment -->

  <keepblanks>



  </keepblanks>

<!-- Comment -->

</root>
END


chomp $maxi;
chomp $minikeepblanks;

is(minify($maxi, no_prolog => 1, keep_comments => 1), $minikeepblanks, "Keep blanks in text nodes where parent has only multiple child nodes but not empty (2)");



done_testing;

