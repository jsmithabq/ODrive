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
=begin
  ds = DB[:pg_database]
  ds.each do |db|
    puts("Database name: #{db[:datname]}.")
  end
=end
  puts
  DB.tables.each do |table|
    puts("Table: #{table}")
    table_schema = DB.schema(table)
    i = 0
    print("  Columns (#{table_schema.size}): ")
    table_schema.each do |column|
      print("  #{column[0]}")
      print(', ') if i < table_schema.size - 1
      i += 1
    end
    puts
  end
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
  status = -1
ensure
  DB.disconnect if DB
end
exit(status)
