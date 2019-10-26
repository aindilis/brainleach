package BrainLeach;

use BOSS::Config;
# use MyFRDCSA;
use PerlLib::MySQL;
use PerlLib::Util;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Config MyMySQL Counter /

  ];

sub init {
  my ($self,%args) = @_;
  $specification = "
	-u [<host> <port>]	Run as a UniLang agent

	-w			Require user input before exiting
";
  # $UNIVERSAL::systemdir = ConcatDir(Dir("internal codebases"),"brainleach");
  $self->Config(BOSS::Config->new
		(Spec => $specification,
		 ConfFile => ""));
  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    $UNIVERSAL::agent->Register
      (Host => defined $conf->{-u}->{'<host>'} ?
       $conf->{-u}->{'<host>'} : "localhost",
       Port => defined $conf->{-u}->{'<port>'} ?
       $conf->{-u}->{'<port>'} : "9000");
  }

  $self->Counter(1);
}

sub Execute {
  my ($self,%args) = @_;

  my $conf = $self->Config->CLIConfig;
  if (exists $conf->{'-u'}) {
    # start the brainleach server, bring up a normal shell, but have
    # commands to change contexts.  the commands should run as separate
    # program, analyzing the data provided.  for instance, could parse
    # bash history.  you would thus need a client program

    # accepts events, calls appropriate handler for various clients,
    # over unilang
    # loop and call handler

    # enter in to a listening loop
    while (1) {
      $UNIVERSAL::agent->Listen(TimeOut => 10);
    }
  }
  if (exists $conf->{'-w'}) {
    Message(Message => "Press any key to quit...");
    my $t = <STDIN>;
  }
}

sub ProcessMessage {
  my ($self,%args) = @_;
  my $m = $args{Message};
  my $it = $m->Contents;
  if ($it) {
    if ($it =~ /^echo\s*(.*)/) {
      $UNIVERSAL::agent->SendContents
	(Contents => $1,
	 Receiver => $m->{Sender});
    } elsif ($it =~ /^(get-next-session-id)$/i) {
      my $res0 = $self->Do(Statement => 'SELECT (max(Session) + 1) as ID FROM metadata');
      if (scalar keys %$res0) {
	my $id = ([keys %$res0]->[0] || 0);
	print "Next Session ID: $id\n";
	$UNIVERSAL::agent->QueryAgentReply
	  (
	   Message => $m,
	   Data => {
		    _DoNotLog => 1,
		    Result => $id,
		   },
	  );
      }
    } elsif ($it =~ /^(quit|exit)$/i) {
      $UNIVERSAL::agent->Deregister;
      exit(0);
    }
  }
  my $d = $m->Data;
  print Dumper({M => $m});
  if (exists $d->{Log}) {
    print Dumper({Arguments => $d->{Log}}) if $UNIVERSAL::debug;
    my $l = $d->{Log};

    # create table metadata (ID int(14) NOT NULL AUTO_INCREMENT PRIMARY KEY, Session int(14), TS datetime);
    $self->Do(Statement => 'INSERT INTO metadata VALUES (NULL,'.$l->{session}.',NOW(6))');
    my $metadataid = $self->MyMySQL->InsertID();
    foreach my $key (sort keys %$l) {

      # create table idx (ID int(14) NOT NULL AUTO_INCREMENT PRIMARY KEY, Contents LONGTEXT);
      my $res1 = $self->Do(Statement => 'SELECT ID FROM idx WHERE Contents = '.$self->Prepare($key));
      my $idx1;
      if (scalar keys %$res1) {
	$idx1 = [keys %$res1]->[0];
      } else {
	my $res1 = $self->Do(Statement => 'INSERT INTO idx VALUES (NULL,'.$self->Prepare($key).')');
	$idx1 = $self->MyMySQL->InsertID();
      }

      my $res2 = $self->Do(Statement => 'SELECT ID FROM idx WHERE Contents = '.$self->Prepare($l->{$key}));
      my $idx2;
      if (scalar keys %$res2) {
	$idx2 = [keys %$res2]->[0];
      } else {
	my $res2 = $self->Do(Statement => 'INSERT INTO idx VALUES (NULL,'.$self->Prepare($l->{$key}).')');
	$idx2 = $self->MyMySQL->InsertID();
      }

      # create table pairs (ID int(14) NOT NULL AUTO_INCREMENT PRIMARY KEY, metadataid int(14), Idx1 int(14), Idx2 int(14), FOREIGN KEY (metadataid) REFERENCES metadata(ID),  FOREIGN KEY (Idx1) REFERENCES idx(ID), FOREIGN KEY (Idx2) REFERENCES idx(ID));
      $self->Do(Statement => 'INSERT INTO pairs VALUES (NULL,'.$metadataid.','.$idx1.','.$idx2.')');
    }
    if ($d->{QueryAgent}) {
      $UNIVERSAL::agent->QueryAgentReply
	(
	 Message => $m,
	 Data => {
		  _DoNotLog => 1,
		  Result => 'Ack',
		 },
	);
    }
    print ".";
    if (!($self->Counter % 80)) {
      $self->Counter(1);
      print "\n";
    } else {
      $self->Counter($self->Counter + 1);
    }
  }

  if (exists $d->{ReplaySession}) {
    my $sid = $d->{ReplaySession};
    my $pid = $d->{EmacsPID};
    if ($pid =~ /^\d+$/ and $sid =~ /^\d+$/) {
      print "Replaying Session $sid on Emacs-Client-$pid\n";
      system "/var/lib/myfrdcsa/codebases/internal/brainleach/scripts/replay-session.pl -s $sid -p $pid";
    } else {
      print "Cannot replay session, SessionID and EmacsPID should be integers\n";
    }
  }
}

sub EnsureConnected {
  my ($self,%args) = @_;
  if (! $self->MyMySQL) {
    print "Connecting\n" if $UNIVERSAL::debug;
    $self->MyMySQL
      (PerlLib::MySQL->new
       (
	DBName => 'brainleach',
       ));
    print "Connected\n" if $UNIVERSAL::debug;
  }
}

sub Prepare {
  my ($self,$text) = @_;
  my $tmp1 = DumperIndent0($text);
  $tmp1 =~ s/^\$VAR1 = //;
  $self->Quote($tmp1);
}

sub Quote {
  my ($self,$text) = @_;
  $self->EnsureConnected();
  $self->MyMySQL->Quote($text);
}

sub Do {
  my ($self,%args) = @_;
  $self->EnsureConnected();
  print Dumper({Statement => $args{Statement}}) if $UNIVERSAL::debug;
  $self->MyMySQL->Do(Statement => $args{Statement});
}

sub GenerateTaskScriptFromLog {
  my ($self,%args) = @_;
  # looking at all the steps, seeing which ones belong to which, and
  # edit which steps belong to which task scripts
}

1;

#   Should be a central server so people can compare notes, take over, in other words, there are clients and a central brainleach server.

#   Should automatically generate docbook summaries.

#   Should have hooks to ask what certain things did.

#   Should generate links and add them to the wiki using MVS.

#   Should have reapplyable scripts.
