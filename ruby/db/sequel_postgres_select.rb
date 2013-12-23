#!/usr/bin/ruby

require 'sequel'

require 'sequel_connect_postgres.rb'

begin
  puts
  puts("Executing: #{ARGV[0]}")
  DB["#{ARGV[0]}"].to_csv.each do |row|
    puts(row)
  end
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
ensure
  DB.disconnect if DB
end
