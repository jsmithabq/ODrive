#!/usr/bin/env ruby

require 'net/http'
require 'json'

host = ARGV.length == 1 ? ARGV[0] : "localhost"

http = Net::HTTP.new(host, 35357)
resp, raw_data = http.post(
  '/v2.0/tokens',
  '{"auth":{"tenantName": "demo", "passwordCredentials":{"username": "test", "password": "secret"}}}',
  {'Content-Type' => 'application/json'}
)
data = JSON.load(raw_data)
puts("Response data:")
puts(JSON.pretty_generate(data))
puts("Token: #{data['access']['token']['id']}")
