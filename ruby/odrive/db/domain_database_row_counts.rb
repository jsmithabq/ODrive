#!/usr/bin/env ruby

require 'base64'
require 'sequel'
require 'postgresql_connection.rb'

user = 'odriver'
password = Base64.decode64('d2Vi')
database = (ARGV.length == 1) ? ARGV[0] : 'whatever'

begin
  DBC = PostgresqlConnection.new('cholla', database, user, password)
  DB = DBC.connect
rescue => e
  puts('Database connection error:')
  exit(-1)
end

begin
  status = 0
  puts
  DB.tables.each do |table|
    puts("Table: #{table}")
    ds = DB[table]
    puts("Row count: #{ds.count}")
#    puts
  end
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
  status = -1
ensure
  DB.disconnect if DB
end
exit(status)
