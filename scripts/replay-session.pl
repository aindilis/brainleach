#!/usr/bin/perl -w

use BOSS::Config;
# use BrainLeach;
# use KBS2::ImportExport;
use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;
use UniLang::Util::TempAgent;

use Time::HiRes qw(usleep);

$specification = q(
	-s <id>		Session ID
	-p <pid>	Emacs PID
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

if (! exists $conf->{'-s'}) {
  die "Need to provide a session ID\n";
}
# if (! exists $conf->{'-p'}) {
#   die "Need to provide an Emacs PID\n";
# }

my $ignore =
  {
   'brainleach-toggle-tracking' => 1,
   'universal-argument' => 1,
   'universal-argument-more' => 1,
  };

# my $importexport = KBS2::ImportExport->new();

my $tempagent = UniLang::Util::TempAgent->new();

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
  my $id = $entry->[0];
  $entries->{$id}->{timestamp} = $entry->[1];
  my $key = MyDeDump($entry->[2]);
  my $value = MyDeDump($entry->[3]);
  $entries->{$id}->{$key->[0]} = $value;
}

my @commands;
my $lasttimestamp;
my $currenttimestamp;
foreach my $key (sort keys %$entries) {
  my $entry = $entries->{$key};
  $currenttimestamp = $entry->{timestamp};
  if (! $lasttimestamp) {
    $lasttimestamp = $currenttimestamp;
  }
  if (exists $entry->{'emacs-command'}) {
    my $delay = $currenttimestamp - $lasttimestamp;
    my $emacscommand = $entry->{'emacs-command'}->[0];
    if ($emacscommand eq 'self-insert-command') {
      if ($entry->{'emacs-command-args'}->[0][0] ne 1) {
	push @commands,
	  {
	   Delay => $delay,
	   Command => '(dotimes (tmp '.$entry->{'emacs-command-args'}->[0][0].') (insert "'.$entry->{'self-insert-char'}->[0].'"))',
	  };
      } else {
	push @commands,
	  {
	   Delay => $delay,
	   Command => '(insert "'.$entry->{'self-insert-char'}->[0].'")',
	  };
      }
    } elsif (! Ignore($emacscommand)) {
      my $toeval;
      if (exists $entry->{'emacs-command-args'}) {
	# print Dumper($entry->{'emacs-command-args'});
	$toeval = '('.$emacscommand.' '.join(' ',map {ConvertArgs(Arg => $_)} @{$entry->{'emacs-command-args'}->[0]}).')';
      } else {
	$toeval = '('.$emacscommand.')';
      }
      push @commands,
	{
	 Delay => $delay,
	 Command => $toeval,
	};
    }
  }
  $lasttimestamp = $currenttimestamp;
}

# print Dumper(\@commands);

foreach my $entry (@commands) {
  my $delay = $entry->{Delay} * 1000000;
  if ($delay < 15000) {
    $delay = 15000;
  }
  usleep($delay);
  my $command = $entry->{Command};
  print $command."\n";
  if (exists $conf->{'-p'}) {
    $tempagent->Send
      (
       Receiver => 'Emacs-Client-'.$conf->{'-p'},
       Contents => 'eval '.$command,
      );
  }
}

# so as to not kill the last message before it's received
sleep(1);


sub MyDeDump {
  my ($todecode) = @_;
  DeDumper('$VAR1 = '.$todecode);
}

sub ConvertArgs {
  my (%args) = @_;
  my $arg = $args{Arg};
  my $type = ref($arg);
  if ($type eq 'HASH' and ! scalar keys %$arg) {
    return 'nil';
  } elsif ($type eq 'ARRAY') {
    # my $res1 = $importexport->Convert
    #   (
    #    InputType => 'Interlingua',
    #    OutputType => 'Emacs String',
    #    Input => [$arg],
    #   );
    my @results;
    foreach my $entry (@$arg) {
      push @results, ConvertArgs(Arg => $entry, DontQuote => 1);
    }
    my $result = '('.join(' ',@results).')';
    if (! $args{DontQuote}) {
      $result = "'".$result;
    }
    return $result;
  } else {
    if ($arg =~ /^[\d]+(\.[\d]+)?$/) {
      return $arg;
    } else {
      return '"'.$arg.'"';
    }
  }
}

sub Ignore {
  my ($emacscommand) = @_;
  exists $ignore->{$emacscommand};
}
