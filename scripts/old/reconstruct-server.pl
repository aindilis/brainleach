#!/usr/bin/perl -w

# reconstruct what software has been installed on this server and what
# custom edits have been performed, store this to a secure environment

# list all the installed packages

my $packages = `dpkg -l`;

# now look at all the files to find which are out of package and which are not

system "sudo updatedb";
system "sudo update-dlocatedb";

my $dlocate = {};
foreach my $file (split /\n/, `dlocate .`) {
  $dlocate->{$file}++;
}
my $locate = {};
foreach my $file (split /\n/, `locate .`) {
  $locate->{$file}++;
}

# this now gives us an idea of what new files are on the system

# throw out stuff in /tmp or /home, etc.

# try to come up with explanations for each of these files that are new to the system

# come up with some method of figuring out which conf files have been
# changed from their original form


