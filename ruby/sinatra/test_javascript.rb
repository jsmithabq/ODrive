#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/
# Visit:  http://localhost:4567/javascript
#

require 'date'
require 'sinatra'

class DateApp < Sinatra::Base

  set :sessions => true
  
  get '/' do
    "According to Ruby, today is: #{DateTime.now.to_s}"
  end

  get '/js-from-file' do
    haml :jsfile
  end

  get '/js-inline' do
    haml :jsinline
  end
end

DateApp.run!
