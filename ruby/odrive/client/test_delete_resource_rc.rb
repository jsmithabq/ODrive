#!/usr/bin/env ruby

#
# = Summary
#

require 'net/http'
require 'test_util.rb'
require 'base64.rb'

include TestUtil

begin
  host, port, resource = get_host_port_resource()
  status = 0
  puts("host = #{host}, port = #{port}, resource = #{resource}")
  credentials = Base64.encode64("testuser:testy")
  resp = RestClient.delete(
    "http://#{host}:#{port}/rest/#{resource}",
    {:cloud_host => 'cloudhost.example.com',
      :cloud_tenant => 'demo', :cloud_user => 'test',
      :cloud_password => 'secret',
      'Authorization' => "Basic #{credentials}"}
  )
  print_response(resp) if resp
rescue => ex
  puts('Exception:')
  #puts("#{ex.class}: #{ex.message}")
  puts(ex)
  status = -1
end
exit(status)

