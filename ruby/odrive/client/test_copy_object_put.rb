#!/usr/bin/env ruby

#
# = Summary
#

require 'test_util.rb'
require 'base64'

include TestUtil

begin
  host, port, resource, source = get_host_port_resource_source()
  credentials = Base64.encode64("testuser:testy")
  status = 0
  puts("host = #{host}, port = #{port}, resource = #{resource}, source = #{source}")
  object = "testfiles/" + File.split(resource)[1]
#  puts(object)
=begin
  resp = RestClient.post("http://#{host}:#{port}/rest/#{resource}",
    ##:file => File.read(object)})
    ##:upfile => File.new(object, 'rb'),
    ##:multipart => true, :file => File.new(object, 'rb'))
    ##'Accept' => 'application/xml',
    :accept => :xml,
    :upfile => File.new(object, 'rb'),
    'X-Copy-From' => "/" + source,
    'X-Object-Meta-whatever' => 'whatever',
    :cloud_host => 'cloudhost.example.com',
    :cloud_tenant => 'demo', :cloud_user => 'test', :cloud_password => 'secret',
    'Authorization' => "Basic #{credentials}"
  )
=end
  site = RestClient::Resource.new("http://#{host}:#{port}/rest/",
    :user => 'testuser', :password => 'testy')
  resp = site[resource].post(
    {:accept => 'application/xml',
      'X-Copy-From' => "/" + source,
      :upfile => File.new(object, 'rb'),
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
