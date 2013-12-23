
#
# == Summary
#
# Defines first-chance routes for ODriveApp.
#
# Uses the demo account, via the default profile for a default "connection,"
# because no authentication is required to visit the home or about pages.
#

class ODriveApp < Sinatra::Base
  get '/stylesheet.css' do
    headers 'Content-Type' => 'text/css; charset=utf-8'

    #sass "#{@default_style}".to_sym
    #style = session[:style] ? 'style' + session[:style].downcase() : @default_style
    style = session[:style] || @default_style
    #style = UserManager.get_user_style(session[:user_id]) || @default_style
    #puts("style to verify = '#{style}'")
    #style = ODRIVE_STYLES[0] if !ODRIVE_STYLES.index(style)
    if !match_condition(ODRIVE_STYLES, lambda {|x| strncmp(style, x)})
      style = ODRIVE_STYLES[0]
    end
    style = 'style' +  style.downcase()
    #puts("style to convert to symbol = '#{style}'")
    sass style.to_sym
  end

  #
  # http://<host>:<port>/<prefix>
  #

  get %r@#{ODRIVE_PREFIX}#{ODRIVE_EXT}@ do
    content_type ODRIVE_FORMAT[get_content_type()]
    
    @stdlog.debug("#{CN}::  (/<prefix>) request.url = #{request.url}.")
    #info = @swift.get_api_info()
    #cloud = ResourceManager.get_parameter(:default_profile).cloud
#=begin
    if is_user_auth_basic?() || is_session_user?()
      cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    else
      cloud = ResourceManager.get_parameter(:default_profile).cloud
    end
#=end
    info = cloud && cloud.get_api_info()
    rr = ResponseRenderer.new(get_content_type())
    if !info
      @heading = "Default Distributed Storage Platform"
      rr.append_class_start("DefaultPlatform")
      @stdlog.debug("#{CN}::  no information available.")
      rr.append_error("No information available.")
    else
      @heading = "#{cloud.name} @ #{cloud.host}"
      rr.append_class_start(cloud.host)
      rr.append_instance_start('api')
      info.each do |k,v|
        rr.append_attr(k, v, 'string')
      end
      rr.append_instance_end()
    end  
    rr.append_class_end()

    @output = rr.data
    handle_response(get_content_type(), :indexcd)
  end

  #
  # http://<host>:<port>
  #

  get %r@#{ODRIVE_HOME}#{ODRIVE_EXT}@ do
    content_type ODRIVE_FORMAT[get_content_type()]
    
    @stdlog.debug("#{CN}::  (/) request.url = #{request.url}.")
    #puts("request is: #{request.inspect}")
    #info = @swift.get_api_info()
    #cloud = ResourceManager.get_parameter(:default_profile).cloud
#=begin
    if is_user_auth_basic?() || is_session_user?()
      cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    else
      cloud = ResourceManager.get_parameter(:default_profile).cloud
    end
#=end
    info = cloud && cloud.get_api_info()
    rr = ResponseRenderer.new(get_content_type())
    if !info
      @heading = "Default Distributed Storage Platform"
      rr.append_class_start("DefaultPlatform")
      @stdlog.debug("#{CN}::  no information available.")
      rr.append_error("No information available.")
    else
      @heading = "#{cloud.name} @ #{cloud.host}"
      rr.append_class_start(cloud.host, get_content_type() == :html)
      rr.append_instance_start('api', get_content_type() == :html)
      info.each do |k,v|
        rr.append_attr(k, v, 'string', get_content_type() == :html)
      end
      rr.append_instance_end()
    end  
    rr.append_class_end()

    @output = rr.data
    #haml get_content_type() == :html ? :indextable : :index
    handle_response(get_content_type(),
      get_content_type() == :html ? :indextable : :indexcd)
  end

  #
  # http://<host>:<port>/<prefix>/about
  #

  get %r@#{ODRIVE_PREFIX + ODRIVE_ABOUT}#{ODRIVE_EXT}@ do
    content_type ODRIVE_FORMAT[get_content_type()]
    
    @stdlog.debug("#{CN}::  (/<prefix>/about) request.url = #{request.url}.")
    #info = @swift.get_api_info()
    #cloud = ResourceManager.get_parameter(:default_profile).cloud
#=begin
    if is_user_auth_basic?() || is_session_user?()
      cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    else
      cloud = ResourceManager.get_parameter(:default_profile).cloud
    end
#=end
    info = cloud && cloud.get_api_info()
    rr = ResponseRenderer.new(get_content_type())
    if !info
      @heading = "Default Distributed Storage Platform"
      rr.append_class_start("DefaultPlatform")
      @stdlog.debug("#{CN}::  no information available.")
      rr.append_error("No information available.")
    else
      @heading = "#{cloud.name} @ #{cloud.host}"
      rr.append_class_start(cloud.host)
      rr.append_instance_start('api')
      info.each do |k,v|
        #puts("k = #{k}, v = #{v}")
        rr.append_attr(k, v, 'string')
       end
      rr.append_instance_end()
    end  
    rr.append_class_end()
    rr2 = ResponseRenderer.new(get_content_type())
    rr2.append_class_start('ODriveApp')
    rr2.append_instance_start('app')
    @app_params.each do |k,v|
      #puts("k = #{k}, v = #{v}")
      rr2.append_attr(k.to_s, v.to_s, 'string')
    end
    rr2.append_instance_end()
    rr2.append_class_end()

    if get_content_type() == :html
      @output = rr.data
      @output_odrive = rr2.data
      handle_response(get_content_type(), :about)
    else
      rrw = ResponseRenderer.new(get_content_type())
      rrw.append_wrapper_start("ODrive")
      rrw.append_wrapper_content(serial_content?(), rr.data, rr2.data)
      rrw.append_wrapper_end()
      @output = rrw.data
      handle_response(get_content_type(), :aboutcd)
    end
  end

  #
  # http://<host>:<port>/about
  #

  get %r@#{ODRIVE_ABOUT}#{ODRIVE_EXT}@ do
    content_type ODRIVE_FORMAT[get_content_type()]
    
    @stdlog.debug("#{CN}::  (/about) request.url = #{request.url}.")
    #info = @swift.get_api_info()
    #cloud = ResourceManager.get_parameter(:default_profile).cloud
#=begin
    if is_user_auth_basic?() || is_session_user?()
      cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    else
      cloud = ResourceManager.get_parameter(:default_profile).cloud
    end
#=end
    info = cloud && cloud.get_api_info()
    rr = ResponseRenderer.new(get_content_type())
    if !info
      @heading = "Default Distributed Storage Platform"
      rr.append_class_start("DefaultPlatform")
      @stdlog.debug("#{CN}::  no information available.")
      rr.append_error("No information available.")
    else
      @heading = "#{cloud.name} @ #{cloud.host}"
      rr.append_class_start(cloud.host, get_content_type() == :html)
      rr.append_instance_start('api', get_content_type() == :html)
      info.each do |k,v|
        rr.append_attr(k, v, 'string', get_content_type() == :html)
      end
      rr.append_instance_end()
    end  
    rr.append_class_end()
    rr2 = ResponseRenderer.new(get_content_type())
    rr2.append_class_start('ODriveApp', get_content_type() == :html)
    rr2.append_instance_start('app', get_content_type() == :html)
    @app_params.each do |k,v|
      rr2.append_attr(k.to_s, v.to_s, 'string', get_content_type() == :html)
    end
    rr2.append_instance_end()
    rr2.append_class_end()

    if get_content_type() == :html
      @output = rr.data
      @output_odrive = rr2.data
      handle_response(get_content_type(), :abouttable)
    else
      rrw = ResponseRenderer.new(get_content_type())
      rrw.append_wrapper_start("ODrive")
      rrw.append_wrapper_content(serial_content?(), rr.data, rr2.data)
      rrw.append_wrapper_end()
      @output = rrw.data
      handle_response(get_content_type(), :aboutcd)
    end
  end
end
