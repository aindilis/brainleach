package BrainLeach::Step;

use Data::Dumper;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / ID Description Contents Context Dependencies TaskScript /

  ];

sub init {
  my ($self,%args) = @_;
  $self->ID($args{ID} || "");
  $self->Description($args{Description} || "");
  $self->Contents($args{Contents} || -1);
  $self->Context($args{Context} || {});
  $self->Dependencies($args{Dependencies} || {});
  $self->TaskScript($args{TaskScript});
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
