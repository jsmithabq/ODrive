#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/
#

require 'sinatra'

class HelloApp < Sinatra::Base

  class << self
    attr_accessor :username, :password
  end
  
  use Rack::Auth::Basic do |username, password|
    HelloApp.username = @@username = username
    HelloApp.password = @@password = password
    [username, password] == ['admin', 'admin']
  end

  get '/' do
    #puts params.inspect
    "#{@@username} -- you're in!"
  end

  get '/about' do
    "#{HelloApp.username}, yes, you're still in--the authentication is global!"
  end
end

HelloApp.run!
