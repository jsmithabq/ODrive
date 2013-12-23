#!/usr/bin/env ruby

#
# = Summary
#

require 'test_util.rb'

include TestUtil

#
# Currently, this test program depends on existence of a default basic auth account.
#

begin
  host, port = get_host_port()
  site = "http://#{host}:#{port}"
  status = 0
  site_resource = RestClient::Resource.new(site,
    :user => 'testuser', :password => 'testy')
  while true
    puts("For site '#{site}', enter resource (or quit):")
    puts
    print "==> "
#    resource = gets().chomp()
    stdin = IO.new(0) # avoid the infamous Errno::ENOENT error from gets()
    resource = stdin.gets().chomp()
    break if resource == 'quit'
    begin
      resp = site_resource[resource].get
    rescue RestClient::ResourceNotFound => ex
      resp = ex
    end
    puts
    print_response(resp)
    puts
  end
rescue => ex
  puts('Exception:')
  #puts("#{ex.class}: #{ex.message}")
  puts(ex)
  status = -1
end
exit(status)
