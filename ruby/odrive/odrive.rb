
#
# == Notice
#
# This file should be run executed (indirectly) from <tt>odrive.sh</tt>,
# in order to pick up the path includes.
#
# == Summary
#
# ODriveApp implements core ODrive resource/route handling.
#
# This application can be extended by including <tt>odrive.rb</tt> and
# augmenting the core functionality with additional route handling.
#
# == Resource Structure
#
#   * http://<host>:<port>/
#   * http://<host>:<port>/about
#   * http://<host>:<port>/<resource>
#   * http://<host>:<port>/<key>.<ext>
#
# == Resource Examples
#
#   * http://localhost:5678/users
#   * http://localhost:5678/users.xml
#   * http://localhost:5678/users/jdoe
#   * http://localhost:5678/users/jdoe.xml
#
#

%w'logger sinatra/base haml sass sequel sequel/extensions/pagination'.each {|lib| require lib}

#%w'postgresql_connection response_renderer odrive_info'.each {|c| require c}
%w'response_renderer odrive_info'.each {|c| require c}

%w'swift_util odrive_config odrive_util db/user_db_util'.each {|m| require m}

%w'models/user_models conditions/init helpers/init routes/init'.each do |comp|
  require comp
end

include ODriveConfig # configuration support
include UserModels # models for user-related tables
include SwiftUtil # mix in cloud provider
include UserDBUtil # mix in user database utility methods (hashing and encryption)
include ODriveUtil # mix in utility methods

#
# ODriveApp is a top-level application.
#

class ODriveApp < Sinatra::Base
  CN = ODriveApp.name

  #set :run, true
  set :sessions, true
  set :port, get_config_value(:local_port, ODRIVE_PORT)

  #
  # Initializes instance variables.
  #

  def initialize()
    super
    @stdlog = ODRIVE_CONFIG.create_logger_from_config(reuse=true)
    cloud_host = get_config_value(:cloud_host, ODRIVE_HOSTS[0])
    #puts("ODriveApp.initialize() begin...")
    profile = OpenStackProfile.new("Swift Object Storage",
      cloud_host,
      get_config_value(:cloud_admin_port, OPENSTACK_ADMIN_PORT),
      get_config_value(:cloud_compute_port, OPENSTACK_COMPUTE_PORT),
      get_config_value(:cloud_tenant, OPENSTACK_DEFAULT_TENANT),
      get_config_value(:cloud_user, OPENSTACK_DEFAULT_USER),
      ODRIVE_AES.encrypt(
        get_config_value(:cloud_password, OPENSTACK_DEFAULT_PASSWORD))
    )
    #puts("default_profile = #{profile}")
    ResourceManager.set_parameter(:default_profile, profile)
    #@swift = route_connection_set_up(:default_profile) # disable later ???
    route_conn = route_connection_set_up(:default_profile, refresh=true)
    if cloud_host != ODRIVE_HOSTS[0]
      ODRIVE_HOSTS << cloud_host
    end
    @emit_url = get_config_value(:emit_url, false)
    @emit_url_for_one_item = get_config_value(:emit_url_for_one_item, false)
    @page_size = get_config_value(:page_size, ODRIVE_PAGE_SIZE).to_i
    @output = "(null)"
    @user_for_profile = nil
    @banner = ODRIVE_DEFAULT_HEADER_FOOTER
    @aes = ODRIVE_AES
    @app_params = {}
    @app_params[:max_file_size] =
      get_config_value(:max_file_size, ODRIVE_MAX_FILE_SIZE.to_s).to_i
    @app_params[:version] = ODRIVE_VERSION
    @default_style = get_config_value(:style, ODRIVE_STYLE)
    #puts("ODriveApp.initialize() finish...")
  end

  #include SwiftUtil # mix in utility methods
  #include ODriveUtil # mix in cloud provider

  ODRIVE_CONFIG.stdlog.debug("#{CN}::  current working directory is '#{get_cwd()}'.")
 end

#ODriveApp.run!
