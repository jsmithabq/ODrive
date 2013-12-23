#!/usr/bin/ruby

require 'sequel'

require '../sequel_connect_postgres.rb'

begin
  puts
  ds = DB[:script]
  ds.each do |script|
#    puts(script.values)
    puts("scriptid: #{script[:scriptid]}, added_date: #{script[:added_date]}")
  end
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
ensure
  DB.disconnect if DB
end
