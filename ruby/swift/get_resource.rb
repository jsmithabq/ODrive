#!/usr/bin/env ruby

#
# = Summary
#

require 'rest_util.rb'

include RestUtil

begin
#endpoint, token = ARGV[0], ARGV[1] if ARGV.length == 2
  endpoint, token = get_endpoint_token()
  status = 0
  site_resource = RestClient::Resource.new(endpoint,
    :headers => {'Accept' => 'application/json', 'X-Auth-Token' => token})
  while true
    puts("For endpoint '#{endpoint}',")
    puts("Enter resource (or quit):")
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

