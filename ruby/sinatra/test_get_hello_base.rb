#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/
#

require 'sinatra/base'

class HelloApp < Sinatra::Base

set :port, 10101

  get '/' do
    'Hello, world!'
  end
end

HelloApp.run!
