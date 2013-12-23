#!/usr/bin/env ruby

#
# = Summary
#

require 'test_util.rb'

include TestUtil

begin
  host, port, resource = get_host_port_resource()
  status = 0
  puts("host = #{host}, port = #{port}, resource = #{resource}")
  site = RestClient::Resource.new("http://#{host}:#{port}/rest/",
    :user => 'testuser', :password => 'testy')
  resp = site[resource].get({'Accept' => 'application/xml',
    :cloud_host => 'cloudhost.example.com',
    :cloud_tenant => 'demo',
    :cloud_user => 'test', :cloud_password => 'secret'}
  )
  puts
  print_response(resp)
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)
