#!/usr/bin/env ruby

#
# = Summary
#

require 'net/http'
require 'test_util.rb'

include TestUtil

begin
  host, port = get_host_port()
  status = 0
=begin
  http = Net::HTTP.new(host, port)
  http.get("/rest/about")
=end
  resp = RestClient.get("http://#{host}:#{port}/rest/about", :accept => 'text/html')
  puts
  print_response(resp)
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)
