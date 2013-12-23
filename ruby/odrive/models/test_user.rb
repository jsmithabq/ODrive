#!/usr/bin/env ruby

#
# = Summary
#
# user_db_display_users lists the current users from the user database.
#
# This script should be executed relative to the web server's working directory.
#

require 'sequel'
require 'sqlite_connection.rb'

begin
  puts
  status = 0
  dbc = SqliteConnection.new('../store/ODriveUserManagement.db')
  db = dbc.connect
  class User < Sequel::Model(:users)
  end
  user = User['testuser']
  puts user.inspect
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
  status = -1
ensure
  dbc.disconnect if dbc
end
exit(status)
