#!/usr/bin/env ruby

#
# = Summary
#

require 'test_util.rb'
require 'base64'

include TestUtil

begin
  host, port = get_host_port()
  credentials = Base64.encode64("testuser:testy")
  status = 0
  resp = RestClient.get("http://#{host}:#{port}/rest/containers.xml",
    {:cloud_host => 'cloudhost.example.com',
      :cloud_tenant => 'demo', :cloud_user => 'test', :cloud_password => 'secret',
      'Authorization' => "Basic #{credentials}"}
  )
  puts
  print_response(resp)
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)
