#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/post/12-29-2010
# Visit:  http://localhost:4567/post/Titanic
#

require 'sinatra'

get %r{/post/(\d\d)-(\d\d)-(\d\d\d\d)} do |month,day,year|
  "Post requested from #{month}/#{day}/#{year}."
end

get '/post/:title' do |title|
  "Post requested with a title of #{title}."
end
