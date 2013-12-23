
All of this functionality is very preliminary.

From the './ruby' directory you can run 'rake' for the default target:

jsmith@server01:~/X/LocalGit/MyDrive/ruby$ rake

These rake targets start web servers on specific ports and, if run from
inside an IDE, terminating the process will likely leave the ports "in
use."  So, it's best to run rake from a dedicated terminal and terminate
the processes with Ctrl-C.

You can also run the 'odrive.sh' script from the command line or load it
inside many IDEs and run it with run/execute functionality that launches
a terminal window, allowing for process termination.

The primary reason for the shell script, as well as the rake targets, is
to set the "include" paths, so that Ruby files can use 'require'
directives that are free of path specs.

Stage 1
  Build RESTful resources for virtually everything.
Stage 2
  Start a pairwise top-down and bottom-up design and development of
  end-user functionality, leveraging the RESTful resources as much as
  possible.
