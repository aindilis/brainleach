package BrainLeach::HTN::Task;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Name Description RTID SubTasks SuperTasks /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Name($args{Name} || "");
  $self->Description($args{Description} || "");
  $self->RTID($args{RTID} || -1);
  $self->SuperTasks($args{SuperTasks} || {});
  $self->SubTasks($args{SubTasks} || {});
}

sub SearchRTForExistingTask {
  my ($self,%args) = @_;
  # go ahead and try to find this task within RT, and use that ticket instead
}

sub AddSubtask {
  my ($self,%args) = @_;
  BrainLeach::HTN::Task->new
      (Name => "root")
}

sub CompleteAndLogTask {
  my ($self,%args) = @_;
  # Mark current task as completed, and add information about the task
  # to the wiki, close the RT ticket if need be

}

1;


# All the different ideas I had.

#   Should be a central server so people can compare notes, take over, in other words, there are clients and a central brainleach server.

#   Should automatically generate docbook summaries.

#   Should have hooks to ask what certain things did.

#   Should generate links and add them to the wiki using MVS.

#   Should have reapplyable scripts.
