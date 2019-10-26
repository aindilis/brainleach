package BrainLeach::Log;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Steps /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Steps
    ($args{Steps} || PerlLib::Collection->new
     (Type => "BrainLeach::Step"));
}

sub ParseLog {
  my ($self,%args) = @_;
  # taking a log, parse out steps
}

1;
