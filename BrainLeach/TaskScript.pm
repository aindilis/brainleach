package BrainLeach::TaskScript;

use Data::Dumper;
use System::Docbook;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Task Steps Dependencies /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Task($args{Steps} || BrainLeach::HTN::Task->new());
  $self->Steps($args{Steps} || []);
  # actually just want to store the various items
  $self->Dependencies
    ($args{Dependencies} ||
     PerlLib::Collection->new
     (Type => "BrainLeach::TaskScript",
      SuperCollection => $UNIVERSAL::BrainLeach::));
}

sub GenerateWiki {
  my ($self,%args) = @_;
  my $docbook = $self->GenerateDocbook;
  my $wiki = $docbook->GenerateWiki;
  $wiki->Upload;
}

sub GenerateDocbook {
  my ($self,%args) = @_;
  my $docbook = System::Docbook->new();
  $docbook->AddTitle($self->Task->PrintDocbook);
  foreach my $step ($self->Steps->Values) {
    $docbook->AddItem($step->PrintDocbook)
  }
  return $docbook;
}

sub ApplyTaskScript {
  my ($self,%args) = @_;
  # if the task is applicable, execute it on the desired machine
}

1;
