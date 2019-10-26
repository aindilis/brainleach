(fix the double kmax-new-shell invocation, when doing it just
 once)

(all do ttyrec of the session at the same time, probably using
 MeMax)

(write code to pull everything into the proper places)

(do we want to involve prolog-agent in the replays?  How should
 that work. it's hard to start up prolog-agent, and could we not
 achieve the same results with just a brainleach agent?  but
 maybe we'd want it to ponder each action in prolog-agent.
 another thing is use prolog timers like we do in FLP.  can do
 IAEC introspection if using Prolog Agent?)

(convert timestamps to milliseconds or microseconds)

(one thing brainleach can do is to record sessions as macros, and
 then name them and store them in a library)

(another thing that brainleach should do is check different
 properties, so if the user is typing, check properties like
 whether they are at the end of the buffer or not.  Use these
 properties as constraints to make sure that, say if the user
 moves forward 5 chars, only in the next one he should have moved
 8, that he gets all the way to the end.  It's a really hard
 problem honestly, but much could be inferred from context.)

(should use execution-engine to steal command line, should use
 universal-parser to parse command line.  not that we have that
 working.)

(2019-09-29 16:45:55 <aindilis> going to work on semi-auto-packaging.  one
 method to do this is to record all edits and commands you run on a
 codebase while packaging, so that you can replay it from a vanilla
 state.  that will help in developing automated packaging agents.

 Should have the ability to take over where you left off or at
 some intermediate point.  That way you could resume when making
 updates to the system.  These should be known checkpoints of
 some sort. )

(maybe IAEC can instrument all the elisp function calls and
 record what values are being passed around)

(There's been a lot of work on deployment like Docker and Vagrant
 and Chef and other provisioning tools.  This is very similar.)

(see kmax-command-log-mode, manager's memax, etc)

(we want the ability to record and play back semantically and
 have everything reexecute correctly.  so we need a virgin VM
 with some gloves for going in and making changes, and then
 restoring and reapplying.)

;;;;; old

(perhaps monitor the system changes using a linux equivalent
 Norton Cleansweep, Your Uninstaller! 2006 and Advanced
 Uninstaller PRO 2006)

;;;;; /old
