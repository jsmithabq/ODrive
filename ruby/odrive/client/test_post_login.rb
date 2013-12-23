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
  resp = RestClient.post("http://#{host}:#{port}/login",
    {:userid => 'testuser', :password => 'testy'},
    {:cookies => {:userid => 'testuser'}})
=end
#=begin
  resource = RestClient::Resource.new("http://#{host}:#{port}")
  resp = resource['login'].post({:userid => 'testuser', :password => 'testy'})
#=end
  puts
  print_response(resp)
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)
