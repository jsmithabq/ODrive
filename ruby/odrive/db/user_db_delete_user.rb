#!/usr/bin/env ruby

#
# = Summary
#
# user_db_delete_user prompts for and then deleted a "doomed" user account.
#
# This script should be executed relative to the web server's working directory.
#

require 'base64'
require 'sequel'
require 'sqlite_connection.rb'

begin
  puts
  if ARGV.length == 1 && ["-h", "-help", "--help"].include?(ARGV[0])
    puts("usage: ruby user_db_delete_user.rb")
    exit(0)
  end
  status = 0
  dbc = SqliteConnection.new('../store/ODriveUserManagement.db')
  db = dbc.connect
  ds = db[:users]
  print("Userid for doomed user: ")
  doomed_user = gets().chomp
  ds2 = ds.filter(:userid => doomed_user)
  if ds2.count == 0
    puts("User doesn't exist: #{doomed_user}")
  elsif ds2.count > 1
    puts("Duplicate users: #{doomed_user}")
  else
    puts("Preparing to delete user: #{doomed_user}")
    print("Delete user: [yes/no] ")
    final_answer = gets().chomp
    puts("You responded: '#{final_answer}'")
    if final_answer == "yes"
      ds2.delete
      puts("Successfully deleted user: #{doomed_user}")
    else
      puts("Deletion abandoned.")
    end
  end
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
  status = -1
ensure
  dbc.disconnect if dbc
end
exit(status)
