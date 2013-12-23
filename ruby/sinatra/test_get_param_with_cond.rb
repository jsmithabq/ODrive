#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/hello
#

require 'sinatra'

get '/hello', :agent => /MSIE 6/ do
  "Seriously?  IE 6? Upgrade and try again."
end

get '/hello', :agent => /Firefox/ do
  "Seriously?  Firefox is such a pig."
end

get '/hello', :agent => /Chromium/ do
  "Seriously?  Chromium is sooo Googleish."
end

get '/hello' do
  "Hello!"
end
