#!/usr/bin/env ruby

#
# = Summary
#
# user_db_display_metadata lists the current metadata for the user database.
#
# This script should be executed relative to the web server's working directory.
#

require 'sequel'
require 'sqlite_connection.rb'

dbc = SqliteConnection.new('../store/ODriveUserManagement.db')
db = dbc.connect

begin
  puts
  if ARGV.length == 1 && ["-h", "-help", "--help"].include?(ARGV[0])
    puts("usage: ruby user_db_display_metadata.rb")
    exit(0)
  end
  status = 0
  db.tables.each do |table|
    puts("Table: #{table}")
    table_schema = db.schema(table)
    print("  Columns (#{table_schema.size}): ")
    table_schema.each_with_index do |column, i|
      print("  #{column[0]}")
      print(', ') if i < table_schema.size - 1
    end
    puts
  end
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
  status = -1
ensure
  dbc.disconnect if dbc
end
exit(status)
