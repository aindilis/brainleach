# brainleach
Emacs programming-by-demonstration record/playback (with state-introspection/constraints) program-synthesis system

BrainLeach has evolved somewhat, originally it was for learning procedures 
from shell sessions, to create documented scripts to achieve different purposes.
I have included the original documentation below.  Now there is an emphasis on
programming-by-demonstration in order to learn how to make Debian packages, 
and other goals.

See also: 

https://frdcsa.org/frdcsa/internal/brainleach

https://github.com/aindilis/execution-engine

and

command log mode from:
https://github.com/aindilis/kmax/blob/master/kmax.el

New documentation:

My main goal at present it to package lots of AI software, and expose
APIs to it, so that people have access to more capabilities.  Pursuant
to this I am working on auto-packaging software.  In the past I wrote
packager, which expedites a lot of the packaging tasks for the user
but packager never learned anything, it just was some hard coded
tricks. So now I'm working on a system that can learn from human
packagers, it's called BrainLeach.  It's sort of a programming-
by-demonstration system.  At this point all it really does is log all
Emacs keys combinations, function invocations and shell commands, and
can replay them.  The idea is to create an intelligent agent that can
work in a GNU/Linux shell/emacs environment.  (see
https://frdcsa.org/~andrewdo/software/domains.lisp) This is a planning
domain for one such agent, called a softbot.  If all the commands for
packaging were specified in such a domain, and we had access to the
softbot software itself, this would be almost straightforward.  But I
cannot get ahold of any softbot software unfortunately.  I'm working
on my own such system: https://github.com/aindilis/prolog-agent but
it's a really hard domain.  If anyone is interested in helping, or can
recommend algorithms that would help with learning how to package from
BrainLeach's traces, that would be great.  Since BrainLeach runs in
Emacs, it's capable of adding lots of hooks to record specific state
during execution so like for any shells that are created I have it
exporting the ENV VARs, and other things like that.  You'll need the
rest of FRDCSA to make it work, but fortunately I'm very close to
releasing a public version of the FRDCSA on a 5GB VirtualBox VM

Old Documentation:

    The name Brain Leach was tip  of the tounge humor from Joe Gresham
    regarding this functionality.

    Brainleach records session commands.  It keeps a basic, expandable
    todo list (an [[HTN]]).  There  is a current task context which is
    defined  as a  subset of  goals from  the HTN.   The  most precise
    context  is  obtained  by  taking  the current  task  context  and
    repeatedly applying the following rule:  if all children of a node
    are in the set, the parent is included and the children removed.

    As  atomized commands  are  recorded into  the [[Atomized  Command
    List]],  each  terminal node  in  the  HTN  is associated  with  a
    subsequence of  the [[Atomized  Command List]], called  the [[Task
    Script]], s.t.  foreach element s_i in  S exists s_j in S j>i s.t.
    depends(S_j,S_i), and  that the sequence is  sufficient to achieve
    the task.

    These   commands  can   then   be  reapplied   against  a   system
    automatically to reobtain the result.   It is possible to edit the
    sequences ex post facto.

    All instances of [[task script]] are stored in a database that can
    be consulted  for reference.   There are also  added to  the wiki.
    Tasks in the HTN are associated with RT tickets.

    Based on  closing of  tickets, preference relations,  and possibly
    judgements  of  the complexity  and  necessity  of various  tasks,
    scores are computed  for productivity that are fed  into the score
    system.

    Possibly  there should  be visualization  of the  progress  of the
    systems in [[Problemspace]] or [[Setanta]].

    There  are  checklist   lookups  and  automated  assistance.   The
    computer can take  over the completion of more  complex tasks.  In
    this way, [[task script]]s are automatically developed for various
    tasks and added to a library.

    The [[task script]]s  are also added to the  wiki in docbook style
    formatting.

    Comments are  also solicited from  the user, and the  system often
    asks the user to clarify what the previous steps accomplished.

    The  user is  able to  issue commands  to interact  with  the task
    database.

    For now  it only  works off  the shell and  in emacs  and possibly
    screen, but in the future  should be more responsive to using more
    programs.  The problem is that we cannot currently record them.

    Brainleach gets Emacs input from Manager::Records::Context.

    Should have  an interface  for auto-posting to  RT about  what has
    already been done.

    Records all sessions, so as to provide the ability to review later
    when that code is complete.
