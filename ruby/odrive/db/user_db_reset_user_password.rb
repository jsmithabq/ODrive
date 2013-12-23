#!/usr/bin/env ruby

#
# = Summary
#
# user_db_reset_user_password resets the password for the specified user.
#
# This script should be executed relative to the web server's working directory.
#

require 'sequel'
require 'sqlite_connection.rb'
require 'user_db_util.rb'

include UserDBUtil

begin
  puts
  if ARGV.length != 2
    puts("usage: ruby user_db_reset_user_password.rb <userid> <temp-password>")
    exit(0)
  end
  status = 0
  puts("Resetting password for user: #{ARGV[0]}")
  dbc = SqliteConnection.new('../store/ODriveUserManagement.db')
  db = dbc.connect
  ds = db[:users]
  ds.filter(:userid => ARGV[0]).update(
    :password => encrypt_one_way(ARGV[1]), :password_stale => true)
  puts("Successfully reset password to: #{ARGV[1]}")
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
  status = -1
ensure
  dbc.disconnect if dbc
end
exit(status)
