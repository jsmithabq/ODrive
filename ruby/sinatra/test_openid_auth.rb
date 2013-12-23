#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/
#

require 'sinatra'
require 'openid'
require 'openid/store/filesystem'

class HelloApp < Sinatra::Base

  class << self
    attr_accessor :username, :password
  end
  
  REALM = 'http://localhost:4567'
  RETURN_TO = "#{REALM}/complete"
  
  get '/login/' do
    puts "#{REALM}, #{RETURN_TO}"
    checkid_request = openid_consumer.begin(params[:openid_identifier])
    redirect checkid_request.redirect_url(REALM, RETURN_TO) if checkid_request.send_redirect?(REALM, RETURN_TO)
    checkid_request.html_markup(REALM, RETURN_TO)
  end

  get '/complete' do
    puts "#{REALM}, #{RETURN_TO}"
    response = openid_consumer.complete(params, RETURN_TO)
    return "You are logged in!" if response.status == OpenID::Consumer::Success
    'Could not log you in with your OpenID'
  end
  
  def openid_consumer
    @consumer = OpenID::Consumer.new(session, OpenID::Store::Filesystem.new('auth/store')) if @consumer.nil?
    return @consumer
  end
end

HelloApp.run!
