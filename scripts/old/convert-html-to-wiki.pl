#!/usr/bin/perl -w

use Data::Dumper;

use Convert::Wiki;

my $file = "/tmp/docbook-make/document.txt";
my $txt = `cat $file`;

my $wiki = Convert::Wiki->new();
$wiki->from_txt ( $txt );
die ("Error: " . $wiki->error()) if $wiki->error;
print $wiki->as_wiki();
