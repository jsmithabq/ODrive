
#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

endpoint, token, container, object = ARGV[0], ARGV[1], ARGV[2], ARGV[3] if ARGV.length == 4

uri = URI.parse(endpoint)
http = Net::HTTP.new(uri.host, uri.port)
resp = http.request_head(uri.path + "/" + container + "/" + object, {'X-Auth-Token' => token})
#puts(resp)
resp.each_header do |k,v|
  puts("k = #{k}, v = #{v}")
end

