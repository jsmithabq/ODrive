#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/
#

require 'sinatra'

class HelloApp < Sinatra::Base

  class << self
    attr_accessor :username, :password
  end
  
  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm='HelloApp')
        throw(:halt, [401, "Not authorized\n"])
      end
    end
    
    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials &&
        @auth.credentials == ['admin', 'admin']
    end
  end
  
  get '/' do
    puts params.inspect
    "This page is unrestricted."
  end

  get '/protected' do
    puts params.inspect
    protected!
    "This page is restricted to authenticated users."
  end
end

HelloApp.run!
