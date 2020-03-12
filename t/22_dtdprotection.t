use strict;
use warnings;

use Test::More 0.98;

use XML::Minify qw(minify);

my $maxi = << "END";
<!DOCTYPE root [
<!ELEMENT protectednode (#PCDATA | protectedleaf | unprotectedleaf)*>
<!ELEMENT protectedleaf (#PCDATA)*>
<!ELEMENT unprotectedleaf (#PCDATA)*>

]>
<root>

<protectednode>

<protectedleaf>                       </protectedleaf>
<unprotectedleaf>                       </unprotectedleaf>

</protectednode>
</root>
END

my $mini = << "END";
<root><protectednode>

<protectedleaf>                       </protectedleaf>
<unprotectedleaf>                       </unprotectedleaf>

</protectednode></root>
END



chomp $maxi;
chomp $mini;

# The unprotected leaf is protected because it is a leaf
is(minify($maxi, no_prolog => 1), $mini, "DTD protect node and leaf (but DTD itself is removed)");

$maxi = << "END";
<!DOCTYPE root [
<!ELEMENT protectednode (protectedleaf | unprotectedleaf)*>
<!ELEMENT protectedleaf (#PCDATA)*>
<!ELEMENT unprotectedleaf (#PCDATA)*>

]>
<root>

<protectednode>

<protectedleaf>                       </protectedleaf>
<unprotectedleaf>                       </unprotectedleaf>

</protectednode>
</root>
END

$mini = << "END";
<root><protectednode><protectedleaf>                       </protectedleaf><unprotectedleaf>                       </unprotectedleaf></protectednode></root>
END

chomp $maxi;
chomp $mini;

# The unprotected leaf is protected because it is a leaf
is(minify($maxi, no_prolog => 1), $mini, "DTD does not protect node (but DTD itself is removed)");


done_testing;

