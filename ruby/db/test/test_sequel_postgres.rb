#!/usr/bin/ruby

require 'sequel'

require '../sequel_connect_postgres.rb'

puts("Server version: #{DB.server_version()}")
