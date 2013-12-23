#!/usr/bin/env ruby

#
# = Summary
#
# user_db_add_user add a new user with minimal information.
#
# This script should be executed relative to the web server's working directory.
#

require 'sequel'
require 'sqlite_connection.rb'
require 'user_db_util.rb'

include UserDBUtil

begin
  puts
  if ARGV.length != 3
    puts("usage: ruby user_db_add_user.rb <userid> <temp-password> <full-name>")
    exit(0)
  end
  userid, password, full_name = ARGV[0], ARGV[1], ARGV[2]
  status = 0
  puts("Creating user: #{userid}")
  dbc = SqliteConnection.new('../store/ODriveUserManagement.db')
  db = dbc.connect
  ds = db[:users]
  ds2 = db[:users].filter(:userid => userid)
  if ds2.count > 0
    puts("Cannot add user because #{userid} is already registered.")
    status = -1
  else
    ds.insert(:userid => userid, :password => encrypt_one_way(password), :name => full_name,
      :password_hint => "(none)", :password_stale => true)
    puts("Successfully added user #{userid}.")
  end
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
  status = -1
ensure
  dbc.disconnect if dbc
end
exit(status)
