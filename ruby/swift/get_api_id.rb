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
=end

raw_data = Net::HTTP.new(host, 8774).get('/').body
data = JSON.load(raw_data)
#puts(raw_data)
id = nil
data['versions'].each do |version|
  if version['status'] == "CURRENT"
    id = version['id']
  end
end
puts("Version ID = #{id}")

