#!/usr/bin/ruby

require 'dbi'
require 'base64'

=begin
=end

begin
  user = 'someuser'
  #password = ARGV[0]
  password = Base64.decode64('d2Vi')
  dbh = DBI.connect('DBI:Pg:somedatabase:cholla', user, password)
  result = dbh.select_one('select version()');
  puts("PostgreSQL version: #{result[0]}")
  puts("Available drivers: #{DBI.available_drivers()}")
  puts()
  dbh.tables.each do |table|
    puts("Table: #{table}")
    columns = dbh.columns(table)
    print("  Columns (#{columns.size()}): ")
    i = 0
    columns.each do |column|
      print(column['name'])
      print(', ') if i < columns.size() - 1
      i += 1
    end
    puts()
  end
rescue DBI::DatabaseError => e
  puts('Database error:')
  puts("  Error code: #{e.err}")
  puts("  Error message: #{e.errstr}")
ensure
  dbh.disconnect if dbh
end

