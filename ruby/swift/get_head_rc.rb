#!/usr/bin/env ruby

require 'restclient'

endpoint, token, container = ARGV[0], ARGV[1], ARGV[2] if ARGV.length == 3

#
# doesn't specify an accept format, so returns container names:
#
resp = RestClient.head("#{endpoint}/#{container}",
  {'Accept' => 'application/xml', 'X-Auth-Token' => token})
puts("response object is: '#{resp}'")
puts("response headers are:")
resp.headers.each do |k,v|
  puts("  k = #{k}, v = #{v}")
end
puts("object count is:  #{resp.headers[:x_container_object_count]}")
