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
=begin
  resp = RestClient.put("http://#{host}:#{port}/rest/#{resource}", {"Accept" => "application/xml", "X-Container-Meta-xxx" => "xyx"})
=end
  site = RestClient::Resource.new("http://#{host}:#{port}/rest/",
    :user => 'testuser', :password => 'testy')
  resp = site[resource].put(
    {:accept => 'application/xml',
    'X-Container-Meta-xxx' => 'xyx',
    :cloud_host => 'cloudhost.example.com',
    :cloud_tenant => 'demo', :cloud_user => 'test', :cloud_password => 'secret'}
  )
  puts
  print_response(resp)
rescue => ex
  puts('Exception:')
  #puts("#{ex.class}: #{ex.message}")
  puts(ex)
  status = -1
end
exit(status)
