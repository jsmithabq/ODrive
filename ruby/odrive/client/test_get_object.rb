#!/usr/bin/env ruby

#
# = Summary
#

require 'test_util.rb'
require 'base64'

include TestUtil

begin
  host, port, resource = get_host_port_resource()
  credentials = Base64.encode64("testuser:testy")
  status = 0
  puts("host = #{host}, port = #{port}, resource = #{resource}")
=begin
  site = RestClient::Resource.new("http://#{host}:#{port}/rest/",
    :cloud_host => 'cloudhost.example.com',
    :cloud_tenant => 'demo', :cloud_user => 'test', :cloud_password => 'secret',
    'Authorization' => "Basic #{credentials}"
  )
=end
  site = RestClient::Resource.new("http://#{host}:#{port}/rest/",
    :user => 'testuser', :password => 'testy',
    :cloud_host => 'cloudhost.example.com',
    :cloud_tenant => 'demo', :cloud_user => 'test', :cloud_password => 'secret'
  )
  #resp = site[resource].get({'Accept' => 'application/xml'})
  resp = site[resource].get()
  puts
  print_response(resp)
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)
