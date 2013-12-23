#!/usr/bin/env ruby

require 'json'
require 'restclient'

endpoint, token = ARGV[0], ARGV[1] if ARGV.length == 2

#
# specifies an accept format, so returns a structure, e.g., JSON output:
#
resp = RestClient.get("#{endpoint}",
  {'Accept' => 'application/json', 'X-Auth-Token' => token})
#puts(resp)
data = JSON.load(resp)
data.each do |c|
  puts("Container: #{c['name']}")
  c.each do |k,v|
    puts("  k = #{k}, v = #{v}")
  end
end
