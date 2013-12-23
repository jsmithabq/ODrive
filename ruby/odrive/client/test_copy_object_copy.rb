#!/usr/bin/env ruby

#
# = Summary
#

require 'test_util.rb'

include TestUtil

begin
  host, port, resource, destination = get_host_port_resource_destination()
  status = 0
  puts("host = #{host}, port = #{port}, resource = #{resource}, destination = #{destination}")
  object = "testfiles/" + File.split(resource)[1]
  site = RestClient::Resource.new("http://#{host}:#{port}/rest/",
    :user => 'testuser', :password => 'testy')
  resp = site[resource].post(
    {:accept => 'application/xml',
      'Destination' => "/" + destination,
      'X-Object-Meta-whatever' => 'whatever',
      :cloud_host => 'cloudhost.example.com',
      :cloud_tenant => 'demo',
      :cloud_user => 'test', :cloud_password => 'secret'}
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
