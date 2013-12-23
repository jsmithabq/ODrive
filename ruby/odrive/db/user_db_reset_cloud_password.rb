#!/usr/bin/env ruby

#
# = Summary
#
# user_db_reset_cloud_password resets the cloud password for the specified user.
#
# This script should be executed relative to the web server's working directory.
#

require 'sequel'
require 'sqlite_connection.rb'
require 'user_db_util.rb'

include UserDBUtil

begin
  if ARGV.length != 2
    puts("usage: ruby user_db_reset_cloud_password.rb <odrive-userid> <temp-cloud-password>")
    exit(0)
  end
  status = 0
  puts("Resetting password for user: #{ARGV[0]}")
  aes = UserDBUtil::AESEncryptinator.new()
  dbc = SqliteConnection.new('../store/ODriveUserManagement.db')
  db = dbc.connect
  ds = db[:users]
  #ds.filter(:userid => ARGV[0]).update(:cloud_password => aes.encrypt(ARGV[1]))
  ds.filter(:userid => ARGV[0]).update(:cloud_password => Base64.encode64(ARGV[1]))
  puts("Successfully reset cloud password to: #{ARGV[1]}")
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
  status = -1
ensure
  dbc.disconnect if dbc
end
exit(status)
