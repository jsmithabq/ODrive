#!/usr/bin/env ruby

require 'net/http'
require 'uri'

endpoint, token = ARGV[0], ARGV[1] if ARGV.length == 2

uri = URI.parse(endpoint)
http = Net::HTTP.new(uri.host, uri.port)
#
# doesn't specify an accept format, so returns container names:
#
resp = http.request_get(uri.path + "/", {'X-Auth-Token' => token})
puts(resp)
