#!/usr/bin/ruby

require 'sequel'

require 'sequel_connect_postgres.rb'

begin
  puts
  puts("Executing: #{ARGV[0]}")
  DB.run(ARGV[0])
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
ensure
  DB.disconnect if DB
end
