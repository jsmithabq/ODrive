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
#=begin
  http = Net::HTTP.new(host, port)
  resp = http.delete("/" + resource,
    {'Accept' => 'application/xml',
      'cloud_host' => 'cloudhost.example.com',
      'cloud_tenant' => 'demo',
      'cloud_user' => 'test', 'cloud_password' => 'secret',
      'Authorization' => "Basic #{credentials}"}
  )
  puts(resp)
#=end
=begin
  Net::HTTP.start(host, port) {|http|
    req = Net::HTTP::Get.new("/" + resource)
#    req.basic_auth 'testuser', 'testy'
    response = http.request(req)
    print response.body
  }
=end
rescue => ex
  puts('Exception:')
  #puts("#{ex.class}: #{ex.message}")
  puts(ex)
  status = -1
end
exit(status)

