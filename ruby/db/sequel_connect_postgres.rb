#!/usr/bin/ruby

require 'base64'
require 'sequel'

#
# This script is a place-holder for a more secure solution.
# Web applications will get connection info from the user's environment.
# For standalone scripts, this script should be replaced by some form
# of configuration/property management.
#

begin
  user = 'someuser'
  #password = ARGV[0]
  password = Base64.decode64('d2Vi')
  #DB = Sequel.connect('postgres://<user>:<password>@cholla/somedatabase')
  DB = Sequel.postgres(:host => 'cholla', :database => 'somedatabase',
    :user => user, :password => password)
rescue Sequel::DatabaseError => e
  puts('Database connection error:')
  puts(e)
ensure
  DB.disconnect if DB
end
