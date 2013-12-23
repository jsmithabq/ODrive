#!/usr/bin/env ruby

#
# = Summary
#

require 'test_util.rb'

include TestUtil

begin
  host, port = get_host_port()
  status = 0
  puts
  RestClient.get("http://#{host}:#{port}/").headers.each do |header|
    puts(header.inspect)
  end
  puts
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)
