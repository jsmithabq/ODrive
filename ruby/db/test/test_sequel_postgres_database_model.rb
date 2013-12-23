#!/usr/bin/ruby

require 'sequel'

require '../sequel_connect_postgres.rb'

begin
  puts
  class Script < Sequel::Model(:script)
  end
  puts("script table name: #{Script.table_name}")
  script = Script[1]
  puts("Model-based selection of row with scriptid = 1:")
  puts("=====#{script.inspect}=====")
  puts("script table primary key: #{script.pk}")
  puts("script table scriptid: #{script.scriptid}")
  puts("script table added_date: #{script.added_date}")
  puts("script table content: #{script.content}")
  script_ids = Script.map(:scriptid)
  puts("script map of scriptids: #{script_ids.inspect}")
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
ensure
  DB.disconnect if DB
end
