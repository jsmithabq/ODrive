#!/usr/bin/env ruby

#
# = Summary
#

require 'test_util.rb'

include TestUtil

begin
  host, port = get_host_port()
  status = 0
  resp = RestClient.get("http://#{host}:#{port}/rest")
  puts
  print_response(resp)
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)
