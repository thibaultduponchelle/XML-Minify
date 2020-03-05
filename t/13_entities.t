use strict;
use warnings;

use Test::More 0.98;

use XML::Minify qw(minify);


# chdir to file
chdir 't/data/';

# Actually we test that the processing of entities which is a feature implemeted by xmlprocessor (XML::LibXML) is preserved by our minifier

# Read file
open my $fh, '<', 'entity.xml' or die "Can't open file $!";
print "Before slurp\n";
my $entity = do { local $/; <$fh> };
print "After slurp\n";

my $entityexpanded = << "END";
<catalog xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xi="http://www.w3.org/2001/XInclude" version="1.0">

<strong>Just Another Perl Hacker,</strong>

</catalog>
END
# Same as xmllint entity.xml --noent

my $entitynotexpanded = << "END";
<catalog xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xi="http://www.w3.org/2001/XInclude" version="1.0">

&japh;

</catalog>
END


chomp $entityexpanded;
chomp $entitynotexpanded;

print $entity;

is(minify($entity, no_prolog => 1, expand_entities => 1), $entityexpanded, "Process entities");
is(minify($entity, no_prolog => 1), $entitynotexpanded, "Do not process entities (default)");

done_testing;

