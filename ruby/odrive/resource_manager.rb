
#
# == Summary
#
# ResourceManager implements straightforward functionality for resource
# management-related tasks.
#
# Resources are persisted only for the duration of the web browser that's
# managing the application.
#
#

require 'logger'

#
# Provides an object for managing OpenStack operations per host.
#

class OpenStackProfile
  attr_accessor :name, :host, :admin_port, :compute_port
  attr_accessor :tenant, :user, :password, :cloud
  
  #
  # Instantiates an OpenStack info set.
  #
  # Arguments:
  #   name - the OpenStack name ID - String
  #   host - the OpenStack host - String
  #   admin_port - the OpenStack admin port - String
  #   compute_port - the OpenStack (nova) compute port - String
  #   tenant - the OpenStack tenant name (not ID) - String
  #   user - the OpenStack userid - String
  #   password - the OpenStack password - String
  #
  
  def initialize(
      name="Swift Object Storage", host="(null host)", admin_port="(null admin port)",
      compute_port="(null compute port)", tenant="(null tenant)",
      user="(null user)", password=ODRIVE_AES.encrypt("(null password)"), cloud=nil
      )
    #puts("OpenStackProfile.initialize() begin...")
    @name = name
    @host = host
    @admin_port = admin_port
    @compute_port = compute_port
    @tenant = tenant
    @user = user
    @password = password
    @cloud = cloud
    #puts("OpenStackProfile.initialize() finish...")
  end

  #
  # Instantiates a copy of an OpenStack info set.
  #
  # Arguments:
  #   orig - the source object - OpenStackProfile
  #
  
  def initialize_copy(orig)
    super
    @name = @name.dup
    @host = @host.dup
    @admin_port = @admin_port.dup
    @compute_port = @compute_port.dup
    @tenant = @tenant.dup
    @user = @user.dup
    @password = @password.dup
    @cloud = @cloud.dup
  end

  #
  # Returns a string representation of an OpenStack info set.
  #
  
  def to_s()
    "[name = '#{@name}', host = '#{@host}', admin_port = '#{@admin_port}', \
compute_port = '#{@compute_port}', tenant = '#{@tenant}', user = '#{@user}', \
password = '#{@password}', cloud = '#{@cloud}']"
  end
end

#
# ResourceManager implements straightforward functionality for resource
# management-related tasks.  Resources are persisted only for the duration of
# the application.
#

class ResourceManager  
  @@logger = ODRIVE_CONFIG.create_logger_from_config(reuse=true)
  @@parameters = {}
  now = DateTime.now
  @@parameters[:app_start_time] = now
  @@parameters[:most_recent_update] = now
    
  #
  # Retrieves the entire parameters (hash) object.
  #
  # Returns the hash table for the run-time parameters
  #
  
  def self.get_parameters()
    @@parameters
  end
  
  #
  # Retrieves a parameter by key.
  #
  # Returns the parameter value
  #
  # Arguments:
  #   key - the key for the parameter- Symbol
  #
  
  def self.get_parameter(key)
    @@parameters[key]
  end
  
  #
  # Sets a parameter's value.
  #
  # Returns the parameter value
  #
  # Arguments:
  #   key - the key for the parameter- Symbol
  #   value - the parameter value
  #
  
  def self.set_parameter(key, value)
    @@parameters[key] = value
  end
  
  #
  # Clears a parameter.
  #
  # Returns the result of the <tt>Hash.delete()</tt> operation
  #
  # Arguments:
  #   key - the key for the parameter- Symbol
  #
  
  def self.clear_parameter(key)
    @@parameters.delete(key)
  end
end
