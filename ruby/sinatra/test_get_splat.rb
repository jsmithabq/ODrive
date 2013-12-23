#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/getfile//this/is/the/file/spec/to/test.txt/:xml
#

require 'sinatra'

get '/getfile/*/:format' do
  "You requested #{params[:splat]} in #{params[:format]} format."
end
