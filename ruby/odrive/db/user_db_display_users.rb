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
require 'user_db_util.rb'

include UserDBUtil

begin
  if ARGV.length == 1 && ["-h", "-help", "--help"].include?(ARGV[0])
    puts("usage: ruby user_db_display_users.rb")
    exit(0)
  end
  status = 0
  aes = UserDBUtil::AESEncryptinator.new()
  dbc = SqliteConnection.new('../store/ODriveUserManagement.db')
  db = dbc.connect
  table_schema = db.schema(:users)
  columns = [:userid, :password, :name]
  table_schema.each_with_index do |column, i|
    print("#{column[0]}")
    print(', ') if i < table_schema.size - 1
    columns << column[0] unless columns.include?(column[0])
  end
  puts
  ds = db[:users]
  if ds.count > 0
    ds.each_with_index do |row, i|
      print "#{i + 1}: "
      columns.each do |column|
        print column != :cloud_password ? "#{row[column]}" : "#{aes.decrypt(row[column])}"
        print ", " unless columns.last == column
      end
      puts
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
