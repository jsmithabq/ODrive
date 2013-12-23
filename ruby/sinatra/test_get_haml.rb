#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/
# Visit:  http://localhost:4567/hello/Frank
# Visit:  http://localhost:4567/goodbye/Frank
#

require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

get '/hello/:name' do |name|
  @name = name
  haml :hello
end

get '/goodbye/:name' do |name|
  haml :goodbye, :locals => {:name => name}
end

__END__
@@ layout
%html
  %head
    %title Haml on Sinatra
  %body
    = yield

@@ index
#header
  %h1 Haml on Sinatra
#content
  %p
    This is an example of using Haml with Sinatra.
    Haml is a good alternative to ERB.

@@ hello
%h1= "Hello #{@name}!"

@@ goodbye
%h1= "Goodbye #{name}!"
