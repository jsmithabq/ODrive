#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

endpoint, token = ARGV[0], ARGV[1] if ARGV.length == 2

uri = URI.parse(endpoint)
http = Net::HTTP.new(uri.host, uri.port)
resp = http.request_head(uri.path, {'X-Auth-Token' => token})
#puts(resp)
resp.each_header do |k,v|
  puts("k = #{k}, v = #{v}")
end

