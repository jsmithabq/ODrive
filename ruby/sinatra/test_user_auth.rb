#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/
# Visit:  http://localhost:4567/protected
#

require 'sinatra'

class HelloApp < Sinatra::Base

  set :sessions => true
  
  register do
    def auth(type)
      condition do
        redirect '/login' unless send("is_#{type}?")
      end
    end
  end
  
  helpers do
    def is_user?
      @user != nil
    end
  end
  
  before do
    @user = User.get(session[:user_id])
  end

  get '/' do
    puts params.inspect
    'Hello, anonymous.'
  end

  get '/protected', :auth => :user do
    puts params.inspect
    "Hello, #{@user.userid}."
  end
  
  post '/login' do
    puts params.inspect
    @user = User.authenticate(params)
    if @user
      session[:user_id] = @user.userid
    else
      throw(:halt, [401, "Not authorized\n"])
    end
    
    haml :login
  end
  
  get '/login' do
    puts params.inspect
    
    haml :login
  end
  
  get '/logout' do
    puts params.inspect
    session[:user_id] = nil
  end
end


class User
  
  attr_reader :userid, :password
  
  def initialize(userid, password)
    @userid, @password = userid, password
  end
   @@users = {:admin => User.new('admin', 'admin')}
 
  def User.get(userid)
    userid ? @@users[:"#{userid}"] : nil
  end
  
  #
  # For this simple test, the user is automatically added.
  # If the user comes back via a different browser session
  # and uses a different password, the authenication fails.
  # Users are managed only for the duration of the current
  # web server process.
  #
  
  def User.authenticate(params)
    userid = params[:userid]
    userid_s = :"#{userid}"
    password = params[:password]
    stored_user = @@users[userid_s]
    if !stored_user
      @@users[userid_s] = User.new(userid, password)
    end
    if password != @@users[userid_s].password
      return nil
    else
      return User.new(userid, password)
    end
  end
end

HelloApp.run!
