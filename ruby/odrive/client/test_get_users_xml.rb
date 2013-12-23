#!/usr/bin/env ruby

#
# = Summary
#

require 'test_util.rb'

include TestUtil

begin
  host, port = get_host_port()
  status = 0
=begin
  resp = RestClient.get("http://#{host}:#{port}/rest/users.xml",
    {:user => 'admin', :password => 'admin'})
=end
  site = RestClient::Resource.new("http://#{host}:#{port}/rest/",
    :user => 'testuser', :password => 'testy')
  resp = site["users"].get()
  puts
  print_response(resp)
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)
