#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/
#

require 'sinatra'
require 'haml'

get '/' do
  haml :index
end

get '/ping' do
  haml :ping
end

get '/traceroute' do
  haml :traceroute
end

post '/ping' do
  @host = params[:host]
  @host.gsub!(/"/,'')
  command = "ping -c 3 #{@host}"
  output = IO.popen(command)
  lines = output.readlines
  @results = ""
  lines.each do |line|
    @results << line
  end
  haml :ping
end

post '/traceroute' do
  @host = params[:host]
  @host.gsub!(/"/,'')
  command = "traceroute #{@host}"
  output = IO.popen(command)
  lines = output.readlines
  @results = ""
  lines.each do |line|
    @results << line
  end
  haml :traceroute
end

__END__
@@ layout
%html
  %head
    %title Network Tools
  %body
    #header
      %h1 Network Tools
    #content
      =yield
  %footer
    %a(href='/') Back to Network Tools

@@ index
%p
  Welcome to Network Tools.
%ul
  %li
    %h3
      %a(href='ping') Ping
  %li
    %h3
      %a(href='traceroute') Traceroute

@@ ping
%h3 Ping
%form(action='/ping' method='POST')
  %input(type='text' name='host' value=@host)
  %input(type='submit')
- if defined?(@results)
  %pre= @results

@@ traceroute
%h3 Traceroute
%form(action='/traceroute' method='POST')
  %input(type='text' name='host' value=@host)
  %input(type='submit')
- if defined?(@results)
  %pre= @results
