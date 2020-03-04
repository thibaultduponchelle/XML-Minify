use strict;
use warnings;

use Test::More 0.98;

use XML::Minify qw(minify);

# Actually we test that the xinclude is feature implemeted by xmlprocessor (XML::LibXML) is preserved by our minifier

# chdir to file
# if we were using XML::LibXML parse_file directly, we would not need this trick
chdir 't/data/';

# Read file
open my $fh, '<', 'catalog.xml' or die "Can't open file $!";
my $catalog = do { local $/; <$fh> };

my $cataloginclude = << "END";
<catalog xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xi="http://www.w3.org/2001/XInclude" version="1.0">
   <book id="bk101">
     <author>Chromatic</author>
     <title>Modern Perl</title>
   </book>

   <include>me</include>

   <book id="bk112">
     <author>Damian Conway</author>
     <title>Perl Best Practices</title>
   </book>
</catalog>
END
# Same as xmllint catalog.xml --xinclude

chomp $cataloginclude;

is(minify($catalog, no_prolog => 1), $cataloginclude, "Process xinclude");

done_testing;

