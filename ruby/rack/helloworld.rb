#!/usr/bin/env ruby

#
# Visit:  http://localhost:9000/
#

require 'rack'

class HelloWorld
  def call(env)
    [200, {}, ['Hello, world!']]
  end
end

Rack::Handler::WEBrick.run(HelloWorld.new, :Port => 9000)
