#!/usr/bin/env perl

# Project : XML-Minifier
# Author : Thibault Duponchelle
# xml-minifier.pl does what you expect from it ;)

use XML::LibXML; # To be installed from CPAN 

my $string;

while (<>) {
        $string .= $_;
}

# Reading...
my $parser = XML::LibXML->new();
my $tree = $parser->parse_string($string);
my $root = $tree->getDocumentElement;

# Writing...
my $doc = XML::LibXML::Document->new('1.0', 'UTF-8');

sub traverse($$) {
        my $node = shift;
        my $outnode = shift;
        if(!$node) { 
                return 0; 
        }

        my $name = $node->getName();
        $newnode = $doc->createElement($name);
        if($outnode) {
                $outnode->addChild($newnode);
        }
        $outnode = $newnode;

        my @as = $node->attributes ;
        foreach my $a (@as) { 
                $outnode->setAttribute($a->nodeName, $a->value); 
        }

        ($node->firstChild->data =~ /^\s*$/) or $outnode->appendText($node->firstChild->data);

        foreach my $child ($node->getChildrenByTagName('*')) {
                $outnode->addChild(traverse($child, $outnode));
        }
        return $outnode;
}

my $rootnode = traverse($root, $doc);
$doc->setDocumentElement($rootnode);

print $doc->toString();
