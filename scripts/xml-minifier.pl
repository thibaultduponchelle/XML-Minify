#!/usr/bin/env perl

use XML::Minify 'minify';

use strict;
use warnings;

use Pod::Usage qw(pod2usage);
use Getopt::Long;

my %opt = ();
my $opt_help;
#my ($opt_expand_entities, $opt_remove_blanks_start, $opt_remove_blanks_end);
#my ($opt_remove_empty_text, $opt_remove_cr_lf_everywhere, $opt_remove_spaces_everywhere);
#my ($opt_keep_comments, $opt_keep_cdatas, $opt_keep_pi, $opt_keep_dtd, $opt_no_prolog);
#my ($opt_version, $opt_encoding, $opt_agressive, $opt_help);


GetOptions (
	"expand-entities" => \$opt{expand_entities},
	"remove-blanks-start"   => \$opt{remove_blanks_start},
	"remove-blanks-end"   => \$opt{remove_blanks_end},
	"remove-empty-text"   => \$opt{remove_empty_text},
	"remove-cr-lf-everywhere"   => \$opt{remove_cr_lf_everywhere},
	"remove-spaces-everywhere"   => \$opt{remove_spaces_everywhere},
	"keep-comments"   => \$opt{keep_comments},
	"keep-cdata"   => \$opt{keep_cdatas},
	"keep-pi"   => \$opt{keep_pi},
	"keep-dtd"   => \$opt{keep_dtd},
	"no-prolog"   => \$opt{no_prolog},
	"version=s"   => \$opt{version},
	"encoding=s"   => \$opt{encoding},
	"agressive"   => \$opt{agressive},
	"help"   => \$opt_help          
	) or die("Error in command line arguments (maybe \"$0 --help\" could help ?)\n");

($opt_help) and pod2usage(1);

my $string;

while (<>) {
        $string .= $_;
}

minify($string, %opt);

__END__

=head1 NAME

xml-minifier - Minify XML files

=head1 SYNOPSIS

xml-minifier 

Options:

--expand-entities            expand entities 

--remove-blanks-start        remove blanks before text

--remove-blanks-end          remove blanks after text

--remove-empty-text          remove (pseudo) empty text

--remove-cr-lf-everywhere    remove cr and lf everywhere

--keep-comments              keep comments

--keep-cdata                 keep cdata

--keep-pi                    keep processing instructions

--keep-dtd                   keep dtd

--no-prolog                  remove prolog (version and encoding)

--version                    specify version for the xml

--encoding                   specify encoding for the xml

--agressive                  short alias for agressive mode 

--help                       brief help message

=head1 OPTIONS

=over 4

=item B<--expand-entities>

Expand entities. An entity is like &foo; 

=item B<--remove-blanks-start>

Remove blanks (spaces, carriage return, line feed...) in front of text nodes. 
For instance <tag>    foo bar</tag> will become <tag>foo bar</tag>
Agressive and therefore lossy compression.

=item B<--remove-blanks-end>

Remove blanks (spaces, carriage return, line feed...) at the end of text nodes. 
For instance <tag>foo bar    </tag> will become <tag>foo bar</tag>
Agressive and therefore lossy compression.

=item B<--remove-empty-text>

Remove (pseudo) empty text nodes (spaces, carriage return, line feed...). 
For instance <tag>foo\nbar</tag> will become <tag>foobar</tag>
Agressive and therefore lossy compression.

=item B<--remove-cr-lf-everywhere>

Remove carriage returns and line feed everywhere (inside text !). Very agressive and therefore lossy compression.

=item B<--keep-comments>

Keep comments, by default they are removed. A comment is like <!-- comment -->

=item B<--keep-cdata>

Keep cdata, by default they are removed. A CDATA is like <![CDATA[ my cdata ]]>

=item B<--keep-pi>

Keep processing instructions. A processing instruction is like <?xml-stylesheet href="style.css"/>

=item B<--keep-dtd>

Keep DTD.

=item B<--no-version>

Do not put any version.

=item B<--version>

Specify version.

=item B<--encoding>

Specify encoding.

=item B<--agressive>

Short alias for agressive mode. Enables options --remove-blanks-starts --remove-blanks-end --remove-empty-text --remove-cr-lf-eveywhere if they are not defined only.
Other options still keep their value.

=item B<--help>

Print a brief help message and exits.

=back

=head2 DESCRIPTION

B<This program> will read the standard input and minify

=over 4

Remove all useless formatting between nodes.
Remove dtd (configurable).
Remove processing instructions (configurable)
Remove comments (configurable).
Remove CDATA (configurable).

This is the default and should be perceived as lossyless minification in term of semantic (but it's not completely if you consider these things as data).
If you want a full lossyless minification,  just use --keep arguments.

In addition, you could be agressive and remove characters in the text nodes (sort of "cleaning") : 
Remove empty text nodes (configurable).
Remove starting blanks (carriage return, line feed, spaces...) (configurable).
Remove ending blanks (carriage return, line feed, spaces...) (configurable).
Remove carriage returns and line feed into text node everywhere (configurable).

=back

=cut


