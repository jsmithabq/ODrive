#!/usr/bin/env ruby

#
# = Summary
#

require 'net/http'
require 'test_util.rb'
require 'base64'

include TestUtil

begin
  host, port, resource = get_host_port_resource()
  credentials = Base64.encode64("testuser:testy")
  status = 0
  puts("host = #{host}, port = #{port}, resource = #{resource}")
  http = Net::HTTP.new(host, port)
  File.open(File.split(resource)[1], 'wb') do |f|
    http.get("/rest/" + resource,
      {'cloud_host' => 'cloudhost.example.com',
        'cloud_tenant' => 'demo', 'cloud_user' => 'test',
        'cloud_password' => 'secret',
        'Accept' => 'application/octet-stream',
        'Authorization' => "Basic #{credentials}"}
    ) do |str|
      f.write(str)
    end
  end
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)
