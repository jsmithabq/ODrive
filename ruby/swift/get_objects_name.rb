#!/usr/bin/env ruby

require 'net/http'
require 'uri'

endpoint, token, container = ARGV[0], ARGV[1], ARGV[2] if ARGV.length == 3

uri = URI.parse(endpoint)
http = Net::HTTP.new(uri.host, uri.port)
#
# doesn't specify an accept format, so returns container names:
#
resp = http.request_get(uri.path + "/#{container}", {'X-Auth-Token' => token})
#puts(resp)
puts(resp.body)
