#!/usr/bin/env perl

use strict;
use warnings;

# Project : XML-Minifier
# Author : Thibault Duponchelle
# xml-minifier.pl does what you expect from it ;)

use XML::LibXML; # To be installed from CPAN : sudo cpan -i XML::LibXML 
# CPAN rules !

use Pod::Usage qw(pod2usage);
use Getopt::Long;

my ($opt_expand_entities, $opt_remove_blanks_start, $opt_remove_blanks_end);
my ($opt_remove_empty_text, $opt_remove_cr_lf_everywhere, $opt_remove_spaces_everywhere);
my ($opt_keep_comments, $opt_keep_cdatas, $opt_keep_pi, $opt_keep_dtd, $opt_no_prolog);
my ($opt_version, $opt_encoding, $opt_agressive, $opt_help);
sub traverse($$);


GetOptions (
	"expand-entities" => \$opt_expand_entities,
	"remove-blanks-start"   => \$opt_remove_blanks_start,
	"remove-blanks-end"   => \$opt_remove_blanks_end,
	"remove-empty-text"   => \$opt_remove_empty_text,
	"remove-cr-lf-everywhere"   => \$opt_remove_cr_lf_everywhere,
	"remove-spaces-everywhere"   => \$opt_remove_spaces_everywhere,
	"keep-comments"   => \$opt_keep_comments,
	"keep-cdata"   => \$opt_keep_cdatas,
	"keep-pi"   => \$opt_keep_pi,
	"keep-dtd"   => \$opt_keep_dtd,
	"no-prolog"   => \$opt_no_prolog,
	"version=s"   => \$opt_version,
	"encoding=s"   => \$opt_encoding,
	"agressive"   => \$opt_agressive,
	"help"   => \$opt_help          
	) or die("Error in command line arguments (maybe \"$0 --help\" could help ?)\n");

if($opt_agressive) {
	(defined $opt_remove_empty_text) or $opt_remove_empty_text = 1;             # a bit agressive
	(defined $opt_remove_blanks_start) or $opt_remove_blanks_start = 1;         # agressive
	(defined $opt_remove_blanks_end) or $opt_remove_blanks_end = 1;             # agressive
	(defined $opt_remove_cr_lf_everywhere) or $opt_remove_cr_lf_everywhere = 1; # very agressive 
	# Others are either overriden or with the correct value (undefined is false)
}

($opt_help) and pod2usage(1);

my $string;

while (<>) {
        $string .= $_;
}

# Configurable with --expand-entities
my $parser = XML::LibXML->new(expand_entities => $opt_expand_entities);
my $tree = $parser->parse_string($string);
$parser->process_xincludes($tree);

my $root = $tree->getDocumentElement;

# I disable automatic xml declaration as : 
# - It would be printed too late (after pi and subset) and produce broken output
# - I want to have full control on it
$XML::LibXML::skipXMLDeclaration = 1;
my $doc = XML::LibXML::Document->new();

my %do_not_remove_blanks = ();

# Traverse the document
sub traverse($$) {
        my $node = shift;
        my $outnode = shift;

	my $name = $node->getName();
	my $newnode = $doc->createElement($name);
	if($outnode) {
		$outnode->addChild($newnode);
	}
	$outnode = $newnode;

        my @as = $node->attributes ;
        foreach my $a (@as) { 
                $outnode->setAttribute($a->nodeName, $a->value); 
        }

        foreach my $child ($node->childNodes) {
		if($child->nodeType eq XML_TEXT_NODE) {
			my $str = $child->data;
		        #print "Text node : $str (". $node->getName() . ") ". @{$child->parentNode->childNodes()} ."\n" ;

			# All these substitutions aim to remove indentation that people tend to put in xml files...
			# ...Or just clean on demand (default behavior keeps these blanks)

			# Configurable with --remove-blanks-start : remove extra space/lf/cr at the start of the string
			$opt_remove_blanks_start and $str =~ s/^\s*//g;
			# Configurable with --remove-blanks-end : remove extra space/lf/cr at the end of the string
			$opt_remove_blanks_end and $str =~ s/\s*$//g;
			# Configurable with --remove-cr-lf-everywhere : remove extra lf/cr everywhere
			$opt_remove_cr_lf_everywhere and $str =~ s/\R*//g;
			# Configurable with --remove-spaces-everywhere : remove extra spaces everywhere
			$opt_remove_spaces_everywhere and $str =~ s/ *//g;
			# Configurable with --remove-empty-text : remove text nodes that contains only space/lf/cr
			$opt_remove_empty_text and $str =~ s/^\s*$//g;

			# Let me explain, we could have text nodes basically everywhere, and we don't know if whitespaces are ignorable or not. 
			# As we want to minify the xml, we can't just keep all blanks, because it is generally indentation or spaces that could be ignored.
			# Here is the strategy : 
			# A. If we have <name>   </name> we should keep it anyway (unless forced with argument)
			# B. If we have </name>   </person> we should remove (in this case parent node contains more than one child node : text node + element node)
			# C. If we have <person>   <name> we should remove it (in this case parent node contains more than one child node : text node + element node)
			# D. If we have </person>   <person> we should remove it (in this case parent node contains more than one child node : text node + element node)
			# B, C, D : remove... unless explicitely declared in DTD as potential #PCDATA container
			if( @{$child->parentNode->childNodes()} > 1 ) { 
				# Should it be configurable ? 
				if(!$do_not_remove_blanks{$child->parentNode->getName()}) {
					# DO NOT REMOVE, PROTECTED BY DTD ELEMENT DECL	
				} else {
					$str =~ s/^\s*$//g;
				}
			} 	 

			$outnode->appendText($str);
		} elsif($child->nodeType eq XML_ENTITY_REF_NODE) {
			# Configuration will be done above when creating document
			my $er = $doc->createEntityReference($child->getName());
			$outnode->addChild($er); 
		} elsif($child->nodeType eq XML_COMMENT_NODE) {
			# Configurable with --keep-comments
			$opt_keep_comments and $outnode->addChild($child);
		} elsif($child->nodeType eq XML_CDATA_SECTION_NODE) {
			# Configurable with --keep-cdata
			$opt_keep_cdatas and $outnode->addChild($child);
		} elsif($child->nodeType eq XML_ELEMENT_NODE) {
			$outnode->addChild(traverse($child, $outnode)); 
		}
	} 
	return $outnode;
}

# Configurable with --no-prolog : do not put prolog (a bit gressive for readers) 
# --version=1.0 --encoding=UTF-8 : choose values
my $version = $opt_version || "1.0";
my $encoding = $opt_encoding || "UTF-8";
$opt_no_prolog or print "<?xml version=\"$version\" encoding=\"$encoding\"?>";

my $rootnode;


# Parsing first level 
foreach my $flc ($tree->childNodes()) {

	if(($flc->nodeType eq XML_DTD_NODE) or ($flc->nodeType eq XML_DOCUMENT_TYPE_NODE)) { # second is synonym but deprecated
		# Configurable with --keep-dtd 
		my $str = $flc->toString();
		# alternative : my $internaldtd = $tree->internalSubset(); my $str = $internaldtd->toString();
		$str =~ s/\R//g;
		$opt_keep_dtd and print $str;
	
		# XML_ELEMENT_DECL
		# XML_ATTRIBUTE_DECL
		# XML_ENTITY_DECL 
		# XML_NOTATION_DECL

		# I need to manually (yuck) parse the node as XML::LibXML does not provide (wrap) such function
		foreach my $dc ($flc->childNodes()) {
			if($dc->nodeType == XML_ELEMENT_DECL) {
				if($dc->toString() =~ /<!ELEMENT\s+(\w+)\s*\(.*#PCDATA.*\)>/) {
					$do_not_remove_blanks{$1} = "Not ignorable due to DTD declaration !";
				}
			}
		}

		# Some notes : 
		# If I iterate over attributes of the childs of DTD (so ELEMENT, ATTLIST etc..) I get a segfault
		# Probable bug from XML::LibXML similar to https://rt.cpan.org/Public/Bug/Display.html?id=71076

		# If I try to access the content of XML_ENTITY_REF_DECL with getValue I get correct result, but on XML_ELEMENT_DECL I get empty string
		# Seems like there's no function to play with DTD
		# I guess we need to write the perl binding for xmlElementPtr xmlGetDtdElementDesc (xmlDtdPtr dtd, const xmlChar * name)

		# If I try to iterate over childNodes, I never see XML_NOTATION_DECL (why?!)

		# One word about DTD and XML::LibXML : 
		# DTD validation works like a charm of course... 
		# But reading from one xml and set to another with experimental function seems just broken or works very weirdly
		# Segfault when reading big external subset, weird message "can't import dtd" when trying to add DTD...

	} elsif($flc->nodeType eq XML_PI_NODE) {
		# Configurable with --keep-pi
		$opt_keep_pi and print $flc->toString();
	} elsif($flc->nodeType eq XML_COMMENT_NODE) {
		# Configurable with --keep-comments
		$opt_keep_comments and print $flc->toString();
	} elsif($flc->nodeType eq XML_ELEMENT_NODE) { # Actually document node as if we do getDocumentNode
		# "main" tree, only one (parser is protecting us)
		$rootnode = traverse($root, $doc);
		# XML_ATTRIBUTE_NODE
		# XML_TEXT_NODE
		# XML_ENTITY_REF_NODE
		# XML_COMMENT_NODE
		# XML_CDATA_SECTION_NODE

		# Ignore 
		# XML_XINCLUDE_START
		# XML_XINCLUDE_END
		
		# Will stay hidden in any case
		# XML_NAMESPACE_DECL

		# Not Applicable 
		# XML_DOCUMENT_NODE 
		# XML_DOCUMENT_FRAG_NODE
		# XML_HTML_DOCUMENT_NODE
		
		# What is it ?
		# XML_ENTITY_NODE
		
	} else {
		# Should I print these unattended things ?
		# Should it be configurable ?
	}
		
}
	
# XML_ELEMENT_NODE            => 1
# E.G. : <tag></tag> or <tag/>

# XML_ATTRIBUTE_NODE          => 2
# E.G. : <tag attribute="value">

# XML_TEXT_NODE               => 3
# E.G. : This is a piece of text

# XML_CDATA_SECTION_NODE      => 4
# E.G. : <![CDATA[<sender>John Smith</sender>]]>
# CDATA section (not for parsers)

# XML_ENTITY_REF_NODE         => 5
# Entities like &entity;

# XML_ENTITY_NODE             => 6
# XML_PI_NODE                 => 7 
# Processing Instructions like <?xml-stylesheet href="style.css"> 

# XML_COMMENT_NODE            => 8
# Comments like <!-- comment -->

# XML_DOCUMENT_NODE           => 9
# The document itself

# XML_DOCUMENT_TYPE_NODE      => 10
# E.G. : Deprecated, use XML_DOCUMENT_TYPE_NODE

# XML_DOCUMENT_FRAG_NODE      => 11
# E.G. : Never read, for use, should be created as element node

# XML_NOTATION_NODE           => 12
# E.G. : <!NOTATION GIF SYSTEM "GIF"> seems not working

# XML_HTML_DOCUMENT_NODE      => 13
# E.G. : <catalog></catalog>
# In HTML context, for us, should be treated as a document node

# XML_DTD_NODE                => 14
# E.G. : <!DOCTYPE book PUBLIC "blahblah" "http://www.example.com/docbookx.dtd" [

# XML_ELEMENT_DECL            => 15
# E.G. : <!ELEMENT element-name EMPTY>

# XML_ATTRIBUTE_DECL          => 16
# E.G. : <!ATTLIST image height CDATA #REQUIRED>

# XML_ENTITY_DECL             => 17
# E.G. : <!ENTITY Entity2 "<strong>Entity</strong>">

# XML_NAMESPACE_DECL          => 18
# E.G. : <catalog xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 

# XML_XINCLUDE_START          => 19
# <xi:include href="inc.xml"/> if we process includes

# XML_XINCLUDE_END            => 20
# <xi:include href="inc.xml"/> if we process includes

$doc->setDocumentElement($rootnode);

print $doc->toString();

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


