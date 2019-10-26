package BrainLeach::HTN;

use BrainLeach::HTN::Task;
use Manager::Dialog qw(QueryUser);

# sample class

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / RootTask /

  ];

sub init {
  my ($self,%args) = @_;
  $self->RootTask
    ($args{Tasks} || BrainLeach::HTN::Task->new
     (Name => "root"));
}

1;
