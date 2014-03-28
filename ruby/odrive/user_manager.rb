
#
# == Summary
#
# UserManager implements straightforward functionality for user
# management-related tasks.
#
# Users are persisted to a table named "users" (among others), implemented with
# an embedded SQLite database instance written to a local/relative store.
# Currently, password mangement is based on a one-way, salted hash.
#
# The ORM-related functionality is handled by the Sequel::Model core, plus the
# functionality defined by the local module 'user_models.rb', which interrogates
# the database metadata and defines a Sequel::Model class for each table.
#
# UserManager loads user data from a database on demand and performs all session
# management against the "current user."  That is, a Sequel::Model dataset
# instance that maps to a primary key (e.g., user) constitutes a one-record
# dataset, and, hence, the "user instance" for session management.
#
# All user-related data is managed via the database tables and model instances
# that uniquely identify an entity.  Thus, newly registered users are inserted
# directly into the database.  User profile updates are authenticated against
# and applied directly to the database.
#
# All database operations are wrapped in connection set-up and clean-up
# operations.
#

require 'base64'
require 'md5'
require 'logger'
require 'sequel'
require 'sqlite_connection.rb'
require 'db/user_db_util.rb'
require 'odrive_config.rb'
require 'models/user_models.rb'

include UserDBUtil # encryption/decryption, etc.
include ODriveConfig # configuration support
include UserModels # models for user-related tables

#
# UserManager implements straightforward functionality for user
# management-related tasks.  Users are persisted to a table named "users",
# implemented with a SQLite database instance written to a local/relative store.
#

class UserManager
  CN = UserManager.name

  STATUS_OK = -10000
  USERID_ALREADY_REGISTERED = -10001
  ALREADY_REGISTERED = -10002
  NOT_REGISTERED = -10003
  NOT_AUTHORIZED = -10004
  USER_DB_ERROR = -10005
  USER_PW_ERROR = -10006
  TYPE_ERROR = -10007

=begin
  @@stdlog = Logger.new(LOG_DEVICE[get_config_value(:log_device, 'stdout').to_sym])
  @@stdlog.level = LOG_LEVEL[get_config_value(:log_level, 'info').to_sym]
=end
  @@stdlog = ODRIVE_CONFIG.create_logger_from_config(reuse=true)
  @@dbc = nil
  @@db = nil

  #
  # Determines pagination parameters.
  #
  # Returns an array of <tt>[page, size]</tt>
  #
  # Arguments:
  #   params - the request instance's parameters - Hash
  #

  def self.pagination(params)
    if page = params[:page]
      page = page.to_i
      @@stdlog.debug("#{CN}::  page = #{page}")
      if page_size = params[:size]
        page_size = page_size.to_i
      else
        page_size = get_config_value(:page_size, CONSOLE_PAGE_SIZE).to_i
      end
    end
    [page, page_size]
  end

  #
  # Sets up database connection.
  #

  def self.db_set_up
    user_store = get_config_value(:user_store, USER_STORE_LOCATION)
    begin
      @@dbc = SqliteConnection.new(user_store)
      @@stdlog.debug("#{CN}::  connecting...")
      @@db = @@dbc.connect
      @@stdlog.debug(
        "#{CN}::  connected to user database: '#{user_store}'")
      return true
    rescue => ex
      @@stdlog.debug(
        "#{CN}::  failed to connect to user database: '#{user_store}'")
      @@stdlog.debug("#{CN}::  #{ex.class}: #{ex.message}")
      return false
    end
  end

  #
  # Cleans up database connection.
  #

  def self.db_clean_up()
    @@dbc.disconnect if @@dbc
    @@stdlog.debug("#{CN}::  disconnected from user database...")
  end

=begin
  #
  # Retrieves user status as nil, or a useful non-nil value (a user).
  #
  # Arguments:
  #   userid - the userid - String
  #
  
  def self.exists?(userid)
    User[userid]
  end
=end

  #
  # Retrieves cloud-related, session-user status.
  #
  # Arguments:
  #   userid - the userid - String
  #

  def self.cloud_session?(userid)
    user = User[userid]
    user &&
      user.cloud_tenant != OPENSTACK_INITIAL_TENANT &&
      user.cloud_user != OPENSTACK_INITIAL_USER &&
      user.cloud_password != OPENSTACK_INITIAL_PASSWORD # decrypt both first ???
  end

  #
  # Retrieves user status (exists in the database) as a Boolean.
  #
  # Arguments:
  #   userid - the userid - String
  #

  def self.exists?(userid)
    User[userid] != nil # strictly a Boolean
  end

  #
  # Retrieves user password status.
  #
  # Arguments:
  #   userid - the userid - String
  #

  def self.stale?(userid)
    #User[userid].password_stale
    if !self.db_set_up()
      return false
    else
      user = User[userid]
      if !user
        result = false
      else
        result = user.password_stale
      end
      self.db_clean_up()
      return result
    end
  end

  def self.get_user_auth_basic(request)
    auth ||= Rack::Auth::Basic::Request.new(request.env)
  end

  def self.is_user_auth_basic?(request)
    auth = get_user_auth_basic(request)
    return basic_auth = auth.provided? && auth.basic? && auth.credentials &&
      self.authenticate_against_db?(
        auth.credentials.first, auth.credentials.last)
  end

  #
  # Authenticate existing users.
  #
  # Arguments:
  #   params - the request instance's parameters - Hash
  #

  def self.authenticate(params)
=begin
    userid = params[:userid]
    userid = "(null)" if !userid || userid.length == 0
=end
    userid = params[:userid] || "(null)"
    #userid_s = userid.to_sym
    #password = params[:password]
    self.authenticate_against_db(userid, params[:password])
  end

  #
  # Authenticate existing users against the database.  Also, this method
  # indirectly verifies that the user table is queryable, so that subsequent
  # action can (after authentication) directly access the user table.
  #
  # Arguments:
  #   userid - the userid - String
  #   password - the clear-text password as typed by the user - String
  #

  def self.authenticate_against_db(userid, password)
    if !self.db_set_up()
      return USER_DB_ERROR
    else
      user = User[userid]
      if !user
        result = NOT_REGISTERED
      elsif encrypt_one_way(password) != user.password
        result = NOT_AUTHORIZED
      else
        result = user
      end
      self.db_clean_up()
      return result
    end
  end

  #
  # Authenticate existing users against the database.  Also, this method
  # indirectly verifies that the user table is queryable, so that subsequent
  # action can (after authentication) directly access the user table.
  #
  # Arguments:
  #   userid - the userid - String
  #   password - the clear-text password as typed by the user - String
  #

  def self.authenticate_against_db?(userid, password)
    if !self.db_set_up()
      return false
    else
      user = User[userid]
      if !user
        result = false
      elsif encrypt_one_way(password) != user.password
        result = false
      else
        result = true
      end
      self.db_clean_up()
      return result
    end
  end

  #
  # Retrieves a user's password.
  #
  # Arguments:
  #   userid - the userid - String
  #

  def self.get_user_password(userid)
    if !self.db_set_up()
      return USER_DB_ERROR
    else
      user = User[userid]
      if !user
        result = NOT_REGISTERED
      else
        result = user.password
      end
      self.db_clean_up()
      return result
    end
  end

  #
  # Retrieves a user instance based on userid.
  #
  # Arguments:
  #   userid - the userid - String
  #

  def self.get_user(userid)
    if !self.db_set_up()
      return USER_DB_ERROR
    else
      user = User[userid]
      if !user
        result = NOT_REGISTERED
      else
        result = user
      end
      self.db_clean_up()
      return result
    end
  end

  #
  # Retrieves a user's style.
  #
  # Arguments:
  #   userid - the userid - String
  #

  def self.get_user_style(userid)
    if !self.db_set_up()
      return USER_DB_ERROR
    else
      user = User[userid]
      if !user
        result = NOT_REGISTERED
      else
        result = user.style
      end
      self.db_clean_up()
      return result
    end
  end

  #
  # Retrieves a user attribute.
  #
  # Arguments:
  #   userid - the userid - String
  #   attr - the attribute - Symbol
  #

  def self.get_user_attr(userid, attr)
    if !self.db_set_up()
      return USER_DB_ERROR
    else
      user = User[userid]
      if !user
        result = NOT_REGISTERED
      else
        result = user[attr]
      end
      self.db_clean_up()
      return result
    end
  end

  #
  # Register new users.  (Session management is handled elsewhere.)
  #
  # Arguments:
  #   params - the request instance's parameters - Hash
  #

  def self.register(params)
    name = params[:name]
    userid = params[:userid]
    userid_s = userid.to_sym
    password = params[:password]
    password2 = params[:password2]
    password_hint = params[:password_hint] ? params[:password_hint] : "(none)"
    style = params[:style] ? params[:style] : "Default" # ???
    if password != password2
      return USER_PW_ERROR
    elsif !self.db_set_up()
      return USER_DB_ERROR
    else
      user = User[userid]
      if user
        return USERID_ALREADY_REGISTERED
      else
        encrypted_password = encrypt_one_way(password)
        # no storage connection at registration:
        rp = self.update_create_resource_profile(userid_s, nil, nil, nil, nil)
=begin
        # This technique doesn't work in current version Sequel:
        user = User.create(:userid => userid, :password => encoded_password,
          :name => name, :password_hint => password_hint, :password_stale => false)
=end
        user = User.new
        user.userid = userid
        #user.password = encoded_password
        user.password = encrypted_password
        user.name = name
        user.password_hint = password_hint
        user.style = style # ???
        user.password_stale = false
        user.cloud_host = rp.host
        user.cloud_tenant = rp.tenant
        user.cloud_user = rp.user
        user.cloud_password = rp.password
        user.save
        self.db_clean_up()
        return user
      end
    end
  end

  #
  # Update or create resource profile.
  #
  # Arguments:
  #   userid_s - the userid - Symbol
  #   host - the host - String
  #   tenant - the tenant - String
  #   user - the user - String
  #   password - the (encoded) password - String
  #

  def self.update_create_resource_profile(userid_s, host, tenant, user, password)
    rp = ResourceManager.get_parameter(userid_s)
    rp = ResourceManager.get_parameter(:default_profile).dup if !rp
    rp.host = host || OPENSTACK_INITIAL_HOST
    rp.tenant = tenant || OPENSTACK_INITIAL_TENANT
    rp.user = user || OPENSTACK_INITIAL_USER
    rp.password = password || OPENSTACK_INITIAL_PASSWORD
    if host && tenant && user && password && cloud_session?(userid_s.to_s)
      swift = SwiftProvider.new(rp.name, rp.host, rp.admin_port, rp.compute_port,
        rp.tenant, rp.user, rp.password)
      rp.cloud = (swift && swift.valid?) ? swift : nil
    else
      rp.cloud = nil # remove old value
    end
    ResourceManager.set_parameter(userid_s, rp)
    rp
  end

  #
  # Manage user profile.
  #
  # Arguments:
  #   user - the user instance - Sequel::Model < User
  #   params - the request instance's parameters - Hash
  #

  def self.manage_profile(userid, params)
    name = params[:name]
    password_hint = params[:password_hint]
    password = params[:password]
    style = params[:style]
    result = authenticate_against_db(userid, password)
    if !result.instance_of?(User)
      @@stdlog.debug(
        "#{CN}::  authentication failed (manage profile): #{result}")
      return result
    else
      if !self.db_set_up()
        return USER_DB_ERROR
      else
        user = User[userid]
        user.update(:name => name, :password_hint => password_hint, :style => style)
        @@stdlog.debug("#{CN}::  profile updated.")
        self.db_clean_up()
        return user
      end
    end
  end

  #
  # Manage user password separately from other user profile activity.
  #
  # Arguments:
  #   user - the user instance - Sequel::Model < User
  #   params - the request instance's parameters - Hash
  #

  def self.manage_password(userid, params)
    cur_password = params[:cur_password]
    new_password = params[:new_password]
    new_password2 = params[:new_password2]
    result = authenticate_against_db(userid, cur_password)
    if !result.instance_of?(User)
      @@stdlog.debug(
        "#{CN}::  authentication failed (manage password): #{result}")
      return result
    elsif new_password != new_password2
      return USER_PW_ERROR
    else
      if !self.db_set_up()
        return USER_DB_ERROR
      else
        encrypted_password = encrypt_one_way(new_password)
        user = User[userid]
        user.update(:password => encrypted_password, :password_stale => false)
        self.db_clean_up()
        #user.password = encoded_password
        user.password = encrypted_password
        user.password_stale = false
        return user
      end
    end
  end

  #
  # Manage cloud resources separately from other user profile activity.
  #
  # Arguments:
  #   user - the user instance - Sequel::Model < User
  #   params - the request instance's parameters - Hash
  #

  def self.manage_resource(userid, params)
    cloud_host = params[:cloud_host]
    cloud_tenant = params[:cloud_tenant]
    cloud_user = params[:cloud_user]
    #puts("cloud password = '#{params[:cloud_password]}'")
    encrypted_cloud_password = ODRIVE_AES.encrypt(params[:cloud_password])
    #puts("cloud password = '#{encrypted_cloud_password}'")
    if !self.db_set_up()
      return USER_DB_ERROR
    else
      @@stdlog.debug("#{CN}::  updating cloud resources:")
      @@stdlog.debug("#{CN}::  cloud_host = '#{cloud_host}'")
      @@stdlog.debug("#{CN}::  cloud_tenant = '#{cloud_tenant}'")
      @@stdlog.debug("#{CN}::  cloud_user = '#{cloud_user}'")
      @@stdlog.debug("#{CN}::  cloud_password = '#{encrypted_cloud_password}'")
      user = User[userid]
      user.update(:cloud_host => cloud_host, :cloud_tenant => cloud_tenant,
        :cloud_user => cloud_user, :cloud_password => encrypted_cloud_password)
      self.db_clean_up()
      self.update_create_resource_profile(userid.to_sym, cloud_host,
        cloud_tenant, cloud_user, encrypted_cloud_password)
      return user
    end
  end

  #
  # List users supports a specified subset of attributes, as well as a
  # subset of users.
  #
  # Arguments:
  #   params - the parameters - Hash
  #   userid - the userid - String
  #   attributes - the list of column names, or :all - Array of Symbol
  #   user_subset - the list of users - Array of String - optional
  #

  def self.list_users(params, userid, attributes, *user_subset)
    page, page_size = pagination(params)
    attributes.each do |attr|
      return TYPE_ERROR if !attr.instance_of?(Symbol)
    end
    userid_s = userid.to_sym
    if !self.db_set_up()
      return USER_DB_ERROR
    end
    columns = []
    @@db.schema(:users).each do |column|
      columns << column[0]
    end
    ok = true;
    if attributes.length == 1 && attributes[0] == :all
      attributes = Array.new(columns)
    else
      attributes.each do |attr|
        ok = false if !columns.include?(attr)
      end
    end
    user_list = []
    columns = []
    if ok
      @@db.schema(:users).each do |col|
        columns << [col[0], col[1][:type]] if attributes.include?(col[0])
      end
      ds = nil
      if user_subset.length == 1 && user_subset[0].instance_of?(Array)
        ds = @@db[:users].filter(:userid => user_subset[0])
      else
        ds = @@db[:users]
      end
      ds = ds.paginate(page, page_size) if page
      ds.each do |row|
        user_data = []
        attributes.each do |attr|
          #user_data << (attr == :password ? row[attr].chomp : row[attr])
          user_data << row[attr]
        end
        user_list << user_data
      end
    end
    self.db_clean_up()
    #@@stdlog.debug("#{CN}::  user list for list-users: #{user_list.inspect}")
    return ok ? [user_list, columns] : TYPE_ERROR
  end
end
