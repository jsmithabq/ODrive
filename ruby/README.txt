ODrive

Summary

ODrive, provides an alternative front-end to object-storage services
such as OpenStack Swift.  Currently, ODrive only provides drivers for
Swift.  The objective is to support Ceph RADOSGW, as well as other
services as they come to market.

ODrive provides
  1. A Ruby application server implemented with Sinatra.
  2. A RESTful front-end, which, with driver support, can
     support multiple object-storage services, providing
     common services across object-storage back-end services.
  3. An HTML web interface to object services.

Contents

There are several test directories that are not directly relevant, e.g.,
the test directory for Ramaze, which is not used.  However, the
directory './ruby/odrive/db' includes command-line utilities for examining
the user-management database.

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

5. ODrive creates a user-management database in the following location:

  ./ruby/odrive/store/ODriveUserManagement.db

ODrive provides manual utilities for manipulating the database in the
following directory:

  ./ruby/odrive/db

ODrive's database is for web access to the ODrive application server,
not for access to the backend distributed storage system, e.g., Swift.  
Configuration for distributed storage is managed from the ODrive app
server User Profile page.

ODrive provides open user registration for the app server.  ODrive does
_not_ store each user's password; ODrive creates and stores a salted
hash upon user account creation.  Each log-in attempts reads the
transient password from the log-in text field, applies the salted hash,
and compared the salted hash to the value stored in the database.

ODrive cannot, however, "overrule" the password management for the
target distributed storage.  For example, OpenStack Swift uses an
encrypted password; thus, ODrive stores an encrypted password for the
managed distributed storage account, in order to pass the password to
the distributed storage driver, e.g., ODrive's Swift storage driver.

To use the manual utilities from within the './ruby/odrive/db'
directory, include (reference) the './ruby/odrive' directory, e.g.:

jsmith@sage:~/.../ODrive/ruby/odrive/db$ ruby -I .. user_db_display_users.rb
userid, password, name, password_hint, password_stale, style, cloud_host, cloud_tenant, cloud_user, cloud_password
1: admin, 91608911a1ef6ec3c89c5b3cce2b3dd6, Administrator The Great, (none), false, default, (no cloud host), (no cloud tenant), (no cloud user), (no cloud password)
...

WARNING:  These utilities fully interrogate the database, e.g.,
displaying passwords, so this part of the (developer) filesystem should
be protected from end-users of the ODrive app server.

