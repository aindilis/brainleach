#!/usr/bin/perl -w

use BOSS::Config;
# use BrainLeach;
use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;

$specification = q(
	-s <id>		Session ID
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

if (! exists $conf->{'-s'}) {
  die "Need to provide a session ID\n";
}

my $mysql = PerlLib::MySQL->new
  (
   DBName => 'brainleach',
  );

my $res1 = $mysql->Do
  (
   Statement => 'select m.ID, UNIX_TIMESTAMP(m.TS) as TS, i1.Contents as C1, i2.Contents as C2 from metadata m, pairs p, idx i1, idx i2 where m.Session = '.$conf->{'-s'}.' and m.ID = p.metadataid and p.Idx1 = i1.ID and p.Idx2 = i2.ID',
   Array => 1,
  );
# print Dumper({Res1 => $res1});

my $entries = {};
foreach my $entry (@$res1) {
  print Dumper($entry);
}
