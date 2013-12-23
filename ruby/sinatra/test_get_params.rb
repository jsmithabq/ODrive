#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/hello/
# Visit:  http://localhost:4567/hello/Frank
# Visit:  http://localhost:4567/tell/Frank/Hola,
#

require 'sinatra'

get '/hello/' do  # note the trailing slash, significant with Sinatra
  "Hello!"
end

get '/hello/:name' do
  "Hello, #{params[:name]}!"
end

get '/tell/:name/:greeting' do
  "#{params[:greeting]} #{params[:name]}!"
end
