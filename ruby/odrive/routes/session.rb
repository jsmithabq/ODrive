
#
# == Summary
#
# Defines session-related routes for ODriveApp.
#

class ODriveApp < Sinatra::Base
  #
  # http://<host>:<port>/access-restriction
  #

  get '/access-restriction' do
    userid = session[:user_id]
    if userid && UserManager.exists?(userid)
      @stdlog.debug("#{CN}::  access restriction for user '#{userid}'")
      @output =
      "User <strong>#{userid}</strong> does not have the required privileges."
    else
      @stdlog.debug("#{CN}::  access restricted for unauthorized user.")
      @output = "User is not logged in with the required privileges."
    end
    
    haml :accessrestriction
  end

  #
  # http://<host>:<port>/client-restriction
  #

  get '/client-restriction' do
    if !UserManager.is_user_auth_basic?(request)
      @stdlog.debug("#{CN}::  this operation requires client authentication.")
      @output = "This operation requires client authentication."
    else
      @stdlog.debug("#{CN}::  access restricted for unauthorized user.")
      @output = "User is not logged in with the required privileges."
    end
    
    haml :clientrestriction
  end

  #
  # http://<host>:<port>/session-restriction
  #

  get '/session-restriction' do
    userid = session[:user_id]
    if userid && UserManager.exists?(userid)
      @stdlog.debug("#{CN}::  session restriction for user '#{userid}'")
      @output = "User <strong>#{userid}</strong> has not provided the required \
cloud, storage, or session privileges (possibly, not logged in?)."
    else
      @stdlog.debug("#{CN}::  access restricted for unauthorized user.")
      @output = "User is not logged in with the required cloud, storage, or \
session privileges."
    end
    
    haml :sessionrestriction
  end

  #
  # http://<host>:<port>/authorized-restriction
  #

  get '/authorized-restriction' do
    userid = session[:user_id]
    if userid && UserManager.exists?(userid)
      @stdlog.debug("#{CN}::  authorization restriction for user '#{userid}'")
      @output = "User <strong>#{userid}</strong> has not provided the required \
cloud, storage, or session privileges (or, possibly, not logged in?)."
    else
      @stdlog.debug("#{CN}::  access restricted for unauthorized user.")
      @output = "User is not logged in and has not set the required cloud, \
storage, or session privileges."
    end
    
    haml :authorizedrestriction
  end

  #
  # http://<host>:<port>/testadminrole
  #

  get '/testadminrole', :authenticated => :user, :role => :admin do
    @output =
      "User <strong>#{session[:user_id]}</strong> is authorized for this resource."
    
    haml :testadminrole
  end

  #
  # http://<host>:<port>/testlogin
  #

  get '/testlogin', :authenticated => :user, :status => :stale do
    @output = "User <strong>#{session[:user_id]}</strong> is currently logged in."
    
    haml :testlogin
  end

  #
  # http://<host>:<port>/logout
  #

  get '/logout' do # instead of requiring auth, give logout failure feedback
    userid = session[:user_id]
    if userid
      session[:user_id] = nil
      session[:logout_time] = DateTime.now.to_s
      session[:login_time] = "nil"
      profile = ResourceManager.get_parameter(userid.to_sym) # invalidate cache ???
      if profile
        profile.cloud = nil
        ResourceManager.clear_parameter(userid.to_sym) # invalidate cache ???
      end
      @output = "User <strong>#{userid}</strong> has logged out successfully."
    else
      @output = "Logging out failed--there is no active session."
    end
    
    haml :logoutstatus
  end

  #
  # http://<host>:<port>/login
  #

  get '/login' do
    userid = session[:user_id]
    #if userid && UserManager.exists?(userid)
    if is_user?()
      @stdlog.debug("#{CN}::  login session user_id = #{userid}")
      @output = "User <strong>#{userid}</strong> is currently logged in."
      
      haml :loginstatus
    else
      haml :login
    end
  end

  #
  # http://<host>:<port>/login
  #

  post '/login' do
    user = UserManager.authenticate(params)
    if !user
      @output = "Unknown log-in error #1."
    elsif user == UserManager::NOT_REGISTERED
      @stdlog.debug("#{CN}::  user '#{params[:userid]}' is not registered.")
      @output = "User <strong>#{params[:userid]}</strong> is not registered!"
    elsif user == UserManager::NOT_AUTHORIZED
#      [401, "Not authorized\n"]
      @stdlog.debug("#{CN}::  user '#{params[:userid]}' is not authorized.")
      @stdlog.debug("#{CN}::  password '#{params[:password]}' is not authorized.")
      @output = "For user <strong>#{params[:userid]}</strong>, password is incorrect!"
    elsif user.instance_of?(User)
      @stdlog.debug("#{CN}::  user '#{user.userid}' has been authenticated.")
      session[:user_id] = user.userid # establish the session
      session[:login_time] = DateTime.now.to_s
      session[:logout_time] = "nil"
      session[:style] = user.style
      userid_s = user.userid.to_sym
      @output = "User <strong>#{user.userid}</strong> has logged in successfully."
      profile = ResourceManager.get_parameter(:default_profile)
      new_profile = profile.dup
      new_profile.host = user.cloud_host
      new_profile.tenant = user.cloud_tenant
      new_profile.user = user.cloud_user
      new_profile.password = @aes.decrypt(user.cloud_password) 
      ResourceManager.set_parameter(userid_s, new_profile)
      #route_connection_set_up(userid_s)  # why doesn't this create the cloud??? 
      #route_connection_set_up(userid_s, refresh=true)  # or this???
      # but this does???
      UserManager.update_create_resource_profile(userid_s, user.cloud_host,
        user.cloud_tenant, user.cloud_user, user.cloud_password)
    else
      @output = "Unknown log-in error #2."
    end

    haml :loginstatus
  end

  #
  # http://<host>:<port>/register
  #

  get '/register' do
    
    haml :register
  end

  #
  # http://<host>:<port>/register
  #

  post '/register' do
    user = UserManager.register(params)
    if !user
      @output = "Unknown registration error #1."
    elsif user == UserManager::USER_PW_ERROR
      @stdlog.debug("#{CN}::  password and confirmation password do not match.")
      @output = "Password and confirmation password do not match."
    elsif user == UserManager::USERID_ALREADY_REGISTERED
      @stdlog.debug("#{CN}::  userid '#{params[:userid]}' is used by another user.")
      @output = "Userid <strong>#{params[:userid]}</strong> is used by another user."
    elsif user == UserManager::ALREADY_REGISTERED
      @stdlog.debug("#{CN}::  user '#{params[:userid]}' is already registered.")
      @output = "User <strong>#{params[:userid]}</strong> is already registered!"
    elsif user == UserManager::USER_DB_ERROR
      @stdlog.debug("#{CN}::  for user '#{params[:userid]}', registration failed.")
      @output = "For user <strong>#{params[:userid]}</strong>, registration failed!"
    elsif user.instance_of?(User)
      session[:user_id] = user.userid # establish the session
      route_connection_set_up(user.userid.to_sym)
      @output = "User <strong>#{user.userid}</strong> has registered successfully."
    else
      @output = "Unknown registration error #2."
    end
    
    haml :registerstatus
  end

  #
  # http://<host>:<port>/password
  #

  get '/password', :authenticated => :user do
    
    haml :password
  end

  #
  # http://<host>:<port>/profile
  #

  get '/profile', :authenticated => :user do
    userid = session[:user_id]
    @user_for_profile = UserManager.get_user(userid) || nil
    @odrive_hosts = ODRIVE_HOSTS
    @odrive_no_hosts_list = ODRIVE_NO_HOSTS_LIST
    @odrive_initial_host = ODRIVE_INITIAL_HOST
    @odrive_styles = ODRIVE_STYLES
    @user_style = UserManager.get_user_style(userid) || nil
    #puts("@user_style = #{@user_style}")
    haml :profile
  end

  #
  # http://<host>:<port>/profile-pw
  #

  get '/profile-pw', :authenticated => :user do
    userid = session[:user_id]
    @user_for_profile = UserManager.get_user(userid) || nil
    
    haml :profile
  end

  #
  # http://<host>:<port>/profile-user
  #

  post '/profile-user', :authenticated => :user do
    userid = session[:user_id]
    user = UserManager.manage_profile(userid, params)
    style = params[:style]
    if !user
      @output = "Unknown profile update error #1."
    elsif user == UserManager::NOT_REGISTERED
      @stdlog.debug("#{CN}::  user '#{userid}' is not registered.")
      @output = "User <strong>#{userid}</strong> is not registered!"
    elsif user == UserManager::NOT_AUTHORIZED
      @stdlog.debug("#{CN}::  user '#{userid}' is not authorized.")
      @output = "For user <strong>#{userid}</strong>, password is incorrect!"
    elsif user == UserManager::USER_DB_ERROR
      @stdlog.debug("#{CN}::  for user '#{userid}', profile-update failed.")
      @output = "For user <strong>#{userid}</strong>, profile-update failed!"
    elsif user.instance_of?(User)
      session[:user_id] = user.userid
      session[:style] = style
      @output = "User <strong>#{user.userid}</strong> has updated profile successfully."
    else
      @output = "Unknown profile update error #2."
    end
    
    haml :profilestatus
  end

  #
  # http://<host>:<port>/profile-resource
  #

  post '/profile-resource', :authenticated => :user do
    incomplete_fields = []
    if params[:cloud_host] == ODRIVE_INITIAL_HOST
      incomplete_fields << 'host'
    end
    if params[:cloud_tenant] == OPENSTACK_INITIAL_TENANT
      incomplete_fields << 'tenant'
    end
    if params[:cloud_user] == OPENSTACK_INITIAL_USER
      incomplete_fields << 'user'
    end
    if params[:cloud_password] == @aes.decrypt(OPENSTACK_INITIAL_PASSWORD) ||
        params[:cloud_password] == ''
      incomplete_fields << 'password'
    end
    if incomplete_fields.length > 0
      @output = "Resource profile is incomplete for:  '#{incomplete_fields.inspect}'."
      haml :profilestatus
    else
      #@stdlog.debug("#{CN}::  cloud_host = #{params[:cloud_host]}.")
      userid = session[:user_id]
      user = UserManager.manage_resource(userid, params)
      userid_s = userid.to_sym
=begin
      old_profile = ResourceManager.get_parameter(userid_s)
      old_profile = ResourceManager.get_parameter(:default_profile) if !old_profile
      # make a copy, in order to undo on failure:
      new_profile = old_profile.dup
      new_profile.host = params[:cloud_host]
      new_profile.tenant = params[:cloud_tenant]
      new_profile.user = params[:cloud_user]
      new_profile.password = params[:cloud_password]
      new_profile.cloud = nil
      ResourceManager.set_parameter(userid_s, new_profile)
=end
=begin
      rp = UserManager.update_create_resource_profile(userid_s, params[:cloud_host],
        params[:cloud_tenant], params[:cloud_user],
        @aes.encrypt(params[:cloud_password]))
=end
=begin
      @stdlog.debug("#{CN}::  new resource parameters:")
      ResourceManager.get_parameters().each do |key,value|
        @stdlog.debug("  #{key} = #{value}.")
        if key == userid_s
          @stdlog.debug("  properties = #{value.inspect}.")
        end
      end
=end
      session[:user_id] = user.userid # ???
      cloud = route_connection_set_up(userid_s, refresh=true)
      if !cloud.valid?()
        @output = "Resource profile update failed, most likely due to database authentication."
      else
        begin        
          ResourceManager.set_parameter(:most_recent_update, DateTime.now)
          @output = "Resource profile has been updated successfully."
        rescue Sequel::DatabaseConnectionError => ex
          ResourceManager.set_parameter(:default_profile, old_profile)
          @output = "Resource profile update failed, most likely due to database authentication."
        rescue Sequel::DatabaseConnectionError => ex
          ResourceManager.set_parameter(:default_profile, old_profile)
          @output = "Resource profile update failed, most likely due to database authentication."
        rescue Exception => ex
          ResourceManager.set_parameter(:default_profile, old_profile)
          @output = "Resource profile update failed, due to unknown failure."
        end
      end
=begin
      @stdlog.debug("#{CN}::  current resource parameters:")
      ResourceManager.get_parameters().each do |key,value|
        @stdlog.debug("  #{key} = #{value}.")
        if key == userid_s
          @stdlog.debug("  properties = #{value.inspect}.")
        end
      end
=end

      haml :profilestatus
    end
  end

  #
  # http://<host>:<port>/profile-pw
  #

  post '/profile-pw', :authenticated => :user do
    userid = session[:user_id]
    user = UserManager.manage_password(userid, params)
    if !user
      @output = "Unknown password update error #1."
    elsif user == UserManager::NOT_REGISTERED
      @stdlog.debug("#{CN}::  user '#{userid}' is not registered.")
      @output = "User <strong>#{userid}</strong> is not registered!"
    elsif user == UserManager::NOT_AUTHORIZED
      @stdlog.debug("#{CN}::  user '#{userid}' is not authorized.")
      @output = "For user <strong>#{userid}</strong>, password is incorrect!"
    elsif user == UserManager::USER_PW_ERROR
      @stdlog.debug("#{CN}::  new password and new confirmation password do not match.")
      @output = "New password and new confirmation password do not match."
    elsif user == UserManager::USER_DB_ERROR
      @stdlog.debug("#{CN}::  for user '#{userid}', password-update failed.")
      @output = "For user <strong>#{userid}</strong>, password-update failed!"
    elsif user.instance_of?(User)
      session[:user_id] = user.userid
      @output = "User <strong>#{user.userid}</strong> has updated password successfully."
    else
      @output = "Unknown password update error #2."
    end
    
    @user_for_profile = user || nil
    haml :profilestatus
  end
end
