#!/usr/bin/env ruby

#
# = Summary
#
# user_db_convert_user_passwords upgrades user passwords from Base64 encoding
# to a salted hash.
#
# This script should be executed relative to the web server's working directory.
#

require 'sequel'
require 'sqlite_connection.rb'
require 'odrive_info.rb'

begin
  if ARGV.length != 1 || ["-h", "-help", "--help"].include?(ARGV[0]) ||
      !(ARGV[0] == 'convert' || ARGV[0] == 'list_old' || ARGV[0] == 'list_new')
    puts("usage: ruby user_db_convert_user_passwords.rb <command>")
    exit(0)
  end
  status = 0
  dbc = SqliteConnection.new('../store/ODriveUserManagement.db')
  db = dbc.connect
  ds = db[:users]
  updates = 0
  ds.each do |user|
    if ARGV[0] == 'list_old'
      puts(Base64.decode64(user[:password]))
    elsif ARGV[0] == 'list_new'
      puts(user[:password])
    elsif ARGV[0] == 'convert'
      password = Base64.decode64(user[:password])
      #puts(password)
      ds.filter(:userid => user[:userid]).update(:password => encrypt_one_way(password))
    end
  end
  puts("Successfully converted passwords.") if ARGV[0] == 'convert'
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
  status = -1
ensure
  dbc.disconnect if dbc
end
exit(status)
