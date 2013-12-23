
#!/usr/bin/env ruby

require 'base64'
require 'restclient'

credentials = Base64.encode64("admin:admin")

begin
  status = 0
  resp = RestClient.get("http://localhost:4567/")
  puts(resp)
  resp = RestClient.get("http://localhost:4567/", {'Authorization' => "Basic #{credentials}"})
  puts(resp)
  resp = RestClient.get("http://localhost:4567/protected", {'Authorization' => "Basic #{credentials}"})
  puts(resp)
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)


