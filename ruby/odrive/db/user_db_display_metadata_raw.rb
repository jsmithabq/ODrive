#!/usr/bin/env ruby

#
# = Summary
#
# user_db_display_metadata_raw lists all current metadata for the user database.
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
    puts(table_schema.inspect)
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
