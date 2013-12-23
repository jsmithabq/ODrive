#!/usr/bin/env ruby

require 'json'
require 'restclient'

endpoint, token, container = ARGV[0], ARGV[1], ARGV[2] if ARGV.length == 3

resp = RestClient.get("#{endpoint}/#{container}",
  {'Accept' => 'application/json', 'X-Auth-Token' => token})
data = JSON.load(resp)
data.each do |o|
  puts("Object: #{o['name']}")
  o.each do |k,v|
    puts("  k = #{k}, v = #{v}")
  end
end
