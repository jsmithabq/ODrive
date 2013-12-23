#!/usr/bin/env ruby

require 'net/http'
require 'json'

host = ARGV.length == 1 ? ARGV[0] : "localhost"

=begin
{
  "versions": [
    {
      "status": "CURRENT",
      "updated": "2011-01-21T11:33:21Z",
      "id": "v2.0",
      "links": [
        {
          "href": "http://cloudhost.example.com:8774/v2/",
          "rel": "self"
        }
      ]
    }
  ]
}

Net::HTTP.start(host, 8774) { |http|
  result = http.get('/')
  puts(result.body)
}

http = Net::HTTP.new(host, 8774)
resp = http.get('/')
puts(resp.body)
=end

puts(Net::HTTP.new(host, 8774).get('/').body)

