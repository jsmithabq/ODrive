Summary

ODrive is a Ruby application server implemented with Sinatra.

Requirements

The approx. package requirements include (except for the GIT GUI-related
packages):

apt-get install libjson-ruby libjson-ruby-doc libpgsql-ruby \
  libpgsql-ruby-doc librack-ruby librestclient-ruby libruby \
  libsequel-ruby libsinatra-ruby libsqlite3-ruby rake ruby \
  thin ruby-haml git git-core giggle git-doc git-gui git-man gitk

Running ODrive

1. You can run ODrive from the './ruby' directory with 'rake' using the
default target:

jsmith@sage:~/X/LocalGit/ODrive/ruby$ rake
cd odrive ; ruby -I . odriveapp.rb
SwiftUtil::  log_device = 'swift.log'
ODriveConfig::  log_device = 'overdrive.log'
ODriveConfig::  log_device = 'overdrive.log'
== Sinatra/1.2.6 has taken the stage on 6799 for development with backup from Thin
>> Thin web server (v1.3.1 codename Triple Espresso)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:6799, CTRL+C to stop

These rake targets start web servers on specific ports and, if run from
inside an IDE, terminating the process will likely leave the ports "in
use."  So, it's best to run rake from a dedicated terminal and terminate
the processes with Ctrl-C.

2. You can also run ODrive using the 'odrive.sh' script from the command
line or load it inside many IDEs and run it with run/execute functionality
that launches a terminal window, allowing for process termination.

jsmith@sage:~/X/LocalGit/ODrive/ruby/odrive$ ./odrive.sh
Running ODrive...
SwiftUtil::  log_device = 'swift.log'
ODriveConfig::  log_device = 'overdrive.log'
ODriveConfig::  log_device = 'overdrive.log'
== Sinatra/1.2.6 has taken the stage on 6799 for development with backup from Thin
>> Thin web server (v1.3.1 codename Triple Espresso)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:6799, CTRL+C to stop

3. You can also run ODrive using Rackup:

jsmith@sage:~/X/LocalGit/ODrive/ruby/odrive$ rackup odrive.ru
SwiftUtil::  log_device = 'swift.log'
ODriveConfig::  log_device = 'overdrive.log'
ODriveConfig::  log_device = 'overdrive.log'
>> Thin web server (v1.3.1 codename Triple Espresso)
>> Maximum connections set to 1024
>> Listening on 0.0.0.0:8080, CTRL+C to stop

4. The primary reason for the shell script, as well as the rake targets, is
to set the "include" paths, so that Ruby files can use 'require'
directives that are free of path specs.

Stage 1
  Build RESTful resources for virtually everything.
Stage 2
  Start a pairwise top-down and bottom-up design and development of
  end-user functionality, leveraging the RESTful resources as much as
  possible.
