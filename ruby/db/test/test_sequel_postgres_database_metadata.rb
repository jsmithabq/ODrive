#!/usr/bin/ruby

require 'sequel'

require '../sequel_connect_postgres.rb'

begin
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
ensure
  DB.disconnect if DB
end
