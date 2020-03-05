use strict;
use warnings;

use Test::More 0.98;

use XML::Minify qw(minify);

my $maxi = << "END";
<?xml version="1.0"?>
<?xml-stylesheet href="my-style.css"?>
<!DOCTYPE book PUBLIC "-//OASIS//DTD DocBook V4.1.2//EN" "http://www.oasis-open.org/docbook/xml/4.0/docbookx.dtd" [<!ELEMENT element-name EMPTY>]>
<catalog xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xi="http://www.w3.org/2001/XInclude">
<book/>
<!-- This is a comment-->
<?xml-stylesheet href="my-style.css"?>
</catalog>
END

my $keepcomments = << "END";
<catalog xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xi="http://www.w3.org/2001/XInclude">
<book/>
<!-- This is a comment-->

</catalog>
END

my $keeppi = << "END";
<?xml-stylesheet href="my-style.css"?><catalog xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xi="http://www.w3.org/2001/XInclude">
<book/>


</catalog>
END

my $keepdtd = << "END";
<!DOCTYPE book PUBLIC "-//OASIS//DTD DocBook V4.1.2//EN" "http://www.oasis-open.org/docbook/xml/4.0/docbookx.dtd" [<!ELEMENT element-name EMPTY>]><catalog xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xi="http://www.w3.org/2001/XInclude">
<book/>


</catalog>
END

# TODO : Why pi and dtd are concatenated and why removed comment do not remove line ? 
# We always remove cr lf in and between first level children
# Removed comment only remove comment, not text around
# TODO : We can have a pi not first level child ?

chomp $maxi;
chomp $keepcomments;
chomp $keeppi;
chomp $keepdtd;

is(minify($maxi, no_prolog => 1, keep_comments => 1), $keepcomments, "Keep comments");
is(minify($maxi, no_prolog => 1, keep_pi => 1), $keeppi, "Keep pi");
is(minify($maxi, no_prolog => 1, keep_dtd => 1), $keepdtd, "Keep dtd");

done_testing;

