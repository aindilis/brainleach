#!/usr/bin/perl -w

use Manager::Dialog qw(SubsetSelect QueryUser);

use Data::Dumper;
use System::Docbook;

# need a docbook document, generated from a script

system "rm -rf /tmp/docbook-make";

# guess at segmentation based on date, use same algorithm as the other
# one PerlLib::TimeSeries::Segment

sub EditAndCommentTaskScript {
  my @items = SubsetSelect
    (Set => [split /\n/, `cat ~/.bash_history`],
     NoAllowWrap => 1);

  print Dumper(\@items);

  my @comments = SubsetSelect
    (Set => \@items);

  foreach my $l (@comments) {
    $mask->{$l} = 1;
  }

  my @code;
  foreach my $l (@items) {
    if ($mask->{$l}) {
      if (@code) {
	# join it and add it
	push @results, "<programlisting>\n".join ("\n", @code)."\n</programlisting>\n";
      }
      my $comment = QueryUser("$l\nComment?: ");
      push @results, "<para>$comment</para>\n";
    }
    push @code, $l;
  }
  if (@code) {
    # join it and add it
    push @results, "<programlisting>\n".join ("\n", @code)."\n</programlisting>\n";
  }

  return "<?xml version=\"1.0\"?>
<!DOCTYPE article PUBLIC \"-//OASIS//DTD DocBook XML V4.1.2//EN\" 
\"file:///usr/share/sgml/docbook/dtd/xml/4.1.2/docbookx.dtd\" [
<!ENTITY legal SYSTEM \"legal.xml\">
]>
<article>
  <title>
     Wiki Edit
  </title>
  <sect1 id=\"Programs\">
    <title>Programs</title>
".
  join("\n",@results).
    "\n</sect1>\n</article>\n";
}

sub AddToWiki {
  # first create the docbook
  # then generate the wiki
  my $docbook = System::Docbook->new
    (Source => EditAndCommentTaskScript());
  $docbook->MakeDocument;
  # now take that html file, and convert it to wiki
}

AddToWiki;
