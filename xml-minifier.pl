#!/usr/bin/env perl

# Project : XML-Minifier
# Author : Thibault Duponchelle
# xml-minifier.pl does what you expect from it ;)

use XML::LibXML; # To be installed from CPAN 

my $string;

while (<>) {
        $string .= $_;
}

my $parser = XML::LibXML->new();
my $tree = $parser->parse_string($string);
my $root = $tree->getDocumentElement;

sub traverse($) {
        my $node = shift;
        if(!$node) {  
                return 0; 
        }

        print "<".$node->getName();
        my @as = $node->attributes ;
        foreach my $a (@as) { 
                print  " ".$a->nodeName. "=\"", $a->value. "\""; 
        }
        print ">";
        ($node->firstChild->data =~ /^\s*$/) or print $node->firstChild->data;

        foreach my $child ($node->getChildrenByTagName('*')) {
                traverse($child);

        }
        print "</".$node->getName().">";
        return 1;
}

traverse($root);
