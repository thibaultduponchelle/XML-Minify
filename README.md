[![Kritika Status](https://kritika.io/users/thibaultduponchelle/repos/thibaultduponchelle+xml-minifier/heads/master/status.svg)](https://kritika.io/users/thibaultduponchelle/repos/thibaultduponchelle+xml-minifier)
# NAME

XML::Minify - It's a configurable XML minifier.

# SYNOPSIS

```perl
use XML::Minify qw(minify);

my $xmlstr = "<person>   <name>tib   </name>   <level>  42  </level>  </person>";
minify($xmlstr);
```

Remove all useless formatting between nodes.

Remove dtd (configurable).

Remove processing instructions (configurable)

Remove comments (configurable).

Remove CDATA (configurable).

This is the default and should be perceived as lossyless minification in term of semantic (but it's not completely if you consider these things as data).

If you want a full lossyless minification, just use keep arguments.

In addition, you could be agressive and remove characters in the text nodes (sort of "cleaning") : 

Remove empty text nodes (configurable).

Remove starting blanks (carriage return, line feed, spaces...) (configurable).

Remove ending blanks (carriage return, line feed, spaces...) (configurable).

Remove carriage returns and line feed into text node everywhere (configurable).

## OPTIONS

You can give various options:

- **expand\_entities**

    Expand entities. An entity is like &amp;foo; 

- **remove\_blanks\_start**

    Remove blanks (spaces, carriage return, line feed...) in front of text nodes. 
    For instance 
        &lt;tag>    foo bar&lt;/tag> 
    will become 
        &lt;tag>foo bar&lt;/tag>

    It is agressive and therefore lossy compression.

- **remove\_blanks\_end**

    Remove blanks (spaces, carriage return, line feed...) at the end of text nodes. 
    For instance 
        &lt;tag>foo bar    &lt;/tag> 
    will become 
        &lt;tag>foo bar&lt;/tag>

    It is agressive and therefore lossy compression.

- **remove\_empty\_text**

    Remove (pseudo) empty text nodes (spaces, carriage return, line feed...). 
    For instance 
        &lt;tag>foo\\nbar&lt;/tag> 
    will become 
        &lt;tag>foobar&lt;/tag>

    It is gressive and therefore lossy compression.

- **remove\_cr\_lf\_everywhere**

    Remove carriage returns and line feed everywhere (inside text !). 

    Very agressive and therefore lossy compression.

- **keep\_comments**

    Keep comments, by default they are removed. 
    A comment is like 
        &lt;!-- comment -->

- **keep\_cdata**

    Keep cdata, by default they are removed. 
    A CDATA is like 
        &lt;!\[CDATA\[ my cdata \]\]>

- **keep\_pi**

    Keep processing instructions. 
    A processing instruction is like 
        &lt;?xml-stylesheet href="style.css"/>

- **keep\_dtd**

    Keep DTD.

- **no\_version**

    Do not put any version.

- **version**

    Specify version.

- **encoding**

    Specify encoding.

- **agressive**

    Short alias for agressive mode. 
    Enables options remove\_blanks\_starts remove\_blanks\_end remove\_empty\_text remove\_cr\_lf\_eveywhere if they are not defined only.

    Other options still keep their value.

# LICENSE

Copyright (C) Thibault DUPONCHELLE.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Thibault DUPONCHELLE <thibault.duponchelle@gmail.com>
