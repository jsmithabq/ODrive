
#
# == Summary
#
# SwiftUtil provides classes and mixin methods for OpenStack Swift
# object-storage management.
#

require 'fileutils'
require 'logger'
require 'ostruct'
require 'yaml'
require 'net/http'
require 'uri'
require 'restclient'
require 'db/user_db_util.rb'

include UserDBUtil

=begin
Storage Accounts
Verb        URI                         Description
GET         /account                    List containers
HEAD        /account                    Retrieve account metadata
Storage Containers
Verb        URI                         Description
GET         /account/container          List objects
PUT         /account/container          Create container
DELETE      /account/container          Delete container
HEAD        /account/container          Retrieve container metadata
Storage Objects
Verb        URI                         Description
GET         /account/container/object   Retrieve object
PUT         /account/container/object   Create/Update object
PUT         /account/container/object   Chunked transfer encoding
DELETE      /account/container/object   Delete object
HEAD        /account/container/object   Retrieve object metadata
POST        /account/container/object   Update object metadata
=end

module SwiftUtil
  MN = SwiftUtil.name

  #
  # SwiftUtil configuration file.
  #
  CONFIG_FILE = './swift.config'

  #
  # Acceptable logging devices.
  #
  LOG_DEVICE = {
    :stderr => STDERR,
    :stdout => STDOUT,
  }

  #
  # Acceptable logging levels.
  #
  LOG_LEVEL = {
    :debug => Logger::DEBUG,
    :info => Logger::INFO,
    :warn => Logger::WARN,
    :error => Logger::ERROR,
    :fatal => Logger::FATAL,
  }

  #
  # Handles configuration keys (of any name) and their values via
  # <tt>method_missing()</tt>.
  #
  # Application components can create a new instance to reread configuration
  # settings.
  #

  class Configurator < OpenStruct
    attr_reader :stdlog

    #
    # Instantiates an object based on the specified configuration file.
    #
    # Arguments:
    #   file - the configuration path/file - String
    #

    def initialize(file=CONFIG_FILE)
      super(nil)
      @stdlog = Logger.new(STDOUT)
      @stdlog.level = Logger::DEBUG
      if File.exists?(file)
        YAML.load_file(file).each do |k,v|
          send("#{k}=", v)
        end
        #@stdlog = Logger.new(LOG_DEVICE[get_value(:log_device, 'stdout').to_sym])
        #@stdlog.level = LOG_LEVEL[get_value(:log_level, 'info').to_sym]
        @stdlog = create_logger_from_config(reuse=false)
        @stdlog.debug("#{MN}:: file = #{file}")
        table.each do |k,v|
          @stdlog.debug("#{MN}::  key = #{k}, value = #{v}")
        end
      end
    end

    #
    # Gets the value associated with a configuration attribute--at the time of
    # the instantiation of the respective Configurator.
    #
    # Arguments:
    #   key - the configuration key - Symbol
    #   default - an optional default value, returned if the key is nil - String
    #
    
    def get_value(key, default=nil)
      table[key] || default
    end

    #
    # Creates a logger based on the configuration settings from <tt>swift.config</tt>.
    #
    # Returns the reference to the logger instance.
    #

=begin
    def create_logger_from_config()
      stdlog = Logger.new(LOG_DEVICE[get_config_value(:log_device, 'stdout').to_sym])
      stdlog.level = LOG_LEVEL[get_config_value(:log_level, 'info').to_sym]
      stdlog
    end
=end
    def create_logger_from_config(reuse)
      return @stdlog if (@stdlog && reuse)
      device = get_value(:log_device, 'stdout')
      puts("#{MN}::  log_device = '#{device}'")
      if device.end_with?('.log')
        stdlog = Logger.new(device, 10, 1024000)
      else
        stdlog = Logger.new(LOG_DEVICE[device.to_sym])
      end
      stdlog
    end
  end

  #
  # Gets a snapshot of the configuration settings during start-up operations.
  #

  CONFIG = Configurator.new
  CONFIG.stdlog.debug("#{MN}::  configurator is '#{CONFIG.class}'...")

  #
  # Provides an interface to Swift Object Storage.  All <tt>ODrive</tt>
  # interaction with Swift occurs through <tt>SwiftProvider</tt>.
  #

  class SwiftProvider
    attr_reader :stdlog
    attr_reader :name, :host, :admin_port, :nova_port
    attr_reader :tenant, :user #, :password
    attr_reader :token, :endpoint
    attr_reader :path, :uri, :account

    #
    # Instantiates an object using initialization data from (1) supplied arguments,
    # (2) the <tt>CONFIG</tt> instance of <tt>Configurator</tt>, or lastly (3)
    # arbitrary local constructor defaults.
    #
    # Arguments:
    #   name - the descriptive connection ID - String
    #   host - the host - String
    #   admin_port - the admin port - String
    #   compute_port - the compute port - String
    #   tenant - the tenant - String
    #   user - the user - String
    #   password - the password - String
    #

    def initialize(
        name=CONFIG.get_value(:default_name, 'Swift 1.0'),
        host=CONFIG.get_value(:default_host, 'cloudhost.example.com'),
        admin_port=CONFIG.get_value(:default_admin_port, '35357'),
        nova_port=CONFIG.get_value(:default_nova_port, '8774'),
        tenant=CONFIG.get_value(:default_tenant, 'demo'),
        user=CONFIG.get_value(:default_user, 'test'),
        password=ODRIVE_AES.encrypt(CONFIG.get_value(:default_password, OPENSTACK_DEFAULT_PASSWORD))
      )
      #puts("SwiftProvider.initialize() begin...")
      @stdlog = CONFIG.stdlog()
      @name = name
      @host = host
      @admin_port = admin_port
      @nova_port = nova_port
      @tenant = tenant
      @user = user
      @password = password
      @token, @endpoint = get_token_endpoint()
      @uri = @endpoint && URI.parse(@endpoint)
      @path = @uri && @uri.path
      @account = @path && @path.split('/')[2]
      #puts("SwiftProvider.initialize() finish...")
    end

    #
    # Returns a string representation of an OpenStack info set.
    #
    
    def to_s()
      "[name = '#{@name}', host = '#{@host}', admin_port = '#{@admin_port}', \
nova_port = '#{@nova_port}', tenant = '#{@tenant}', user = '#{@user}', \
password = '#{@password.inspect}', token = '#{@token}', endpoint = '#{@endpoint}', \
uri = '#{@uri}', path = '#{@path}', account = '#{@account}']"
    end

    #
    # Determines the validity of a resource connection instance, e.g., did
    # the token retrieval fail due to a bad tenant, user, password, etc.
    #

    def valid?()
      @token && @endpoint && @uri && @path
    end

    #
    # Initializes instance variables for token and endpoint on behalf of the
    # user by a POST operation for credentials via the admin port.
    #

    def get_token_endpoint()
      begin
        http = Net::HTTP.new(@host, @admin_port)
        body = "{\"auth\": {\"tenantName\": \"#{@tenant}\", \"passwordCredentials\": {\"username\": \"#{@user}\", \"password\": \"#{ODRIVE_AES.decrypt(@password)}\"}}}"
        #puts("credentials body = #{body}")
        headers = {'Content-Type' => 'application/json'}
        resp, raw_data = http.post(
          '/v2.0/tokens', # still hard-coded ???
          body,
          headers
        )
        data = JSON.load(raw_data)
        @token = data['access']['token']['id']
        data['access']['serviceCatalog'].each do |service|
          if service['name'] == "swift"
            @endpoint = service['endpoints'][0]['publicURL']
          end
        end
        return @token, @endpoint
      rescue => ex
        @stdlog.debug(
          "#{MN}::  failed to get token/endpoint for host = '#{@host}', \
port = '#{@admin_port}':")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        return nil, nil
      end
    end

=begin
    {
     "versions": [
       {
         "status": "CURRENT",
         "updated": "2011-01-21T11:33:21Z",
         "id": "v2.0",
         "links": [
           {
             "href": "http://cloudhost.example.com:8774/v2/",
             "rel": "self"
           }
         ]
       }
     ]
   }
=end

    #
    # Queries with a GET operation the compute service for API-related info.
    #

    def get_api_info()
      begin
        @stdlog.debug(
          "#{MN}::  host = '#{@host}', port = '#{@nova_port}', token = '#{@token}'")
        http = Net::HTTP.new(@host, @nova_port)
        resp = http.get('/', {'X-Auth-Token' => @token})
        data = JSON.load(resp.body)
        info = {}
        @stdlog.debug("#{MN}::  resp.body = '#{resp.body}'")
        data['versions'].each do |version|
          version.each do |k,v|
            if k == "links"
              v.each do |link|
                link.each do |kk,vv|
                  if kk == "href"
                    info[kk] = vv
                  end
                end
              end
            else
              info[k] = v
            end
          end
          if version['status'] == "CURRENT"
          end
        end
        info
      rescue => ex
        @stdlog.debug(
          "#{MN}::  failed to get api info for host = '#{@host}', \
port = '#{@nova_port}':")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end
    end

    #
    # Queries with a HEAD operation for metadata.
    #
    # Arguments:
    #   container - the container - String
    #   object - the object - String
    #   all_md - all metadata or an arbitrary subset - Boolean
    #

    def get_metadata(container="", object="", all_md=true)
      raise(ArgumentError, "Expected String, not #{container.class.name}") \
        if !container.instance_of?(String)
      raise(ArgumentError, "Expected String, not #{object.class.name}") \
        if !object.instance_of?(String)
      raise(ArgumentError, "Expected a Boolean, not #{all_md.class.name}") \
        if !(all_md.instance_of?(TrueClass) || all_md.instance_of?(FalseClass))
      begin
        uri = valid?() && URI.parse(@endpoint)
        return md[:error] = "Invalid URI - token/authentication error?" if !uri
        http = Net::HTTP.new(uri.host, uri.port)
        path = uri.path
        path += "/#{container}" if container.length > 0
        path += "/#{object}" if object.length > 0
        resp = http.request_head(path, {'X-Auth-Token' => @token})
        md = {}
        return md[:error] = "Null response from Swift Object Storage." if !resp
        get_all_md = lambda { resp.each_header { |k,v| md[k] = v } }
        if container.length == 0 and object.length == 0 # account
          return md[:error] = "Not authorized." if resp.code == 401
          return get_all_md.call() if all_md
          md['container-count'] = resp['x-account-container-count']
          md['bytes-used'] = resp['x-account-bytes-used']
          md['object-count'] = resp['x-account-object-count']
          md['date'] = resp['date']
        elsif container.length > 0 and object.length == 0 # container
          return md[:error] = "Container does not exist." if resp.code == 404
          return get_all_md.call() if all_md
          md['object-count'] = resp['x-container-object-count']
          md['bytes-used'] = resp['x-container-bytes-used']
          md['content-length'] = resp['content-length']
          md['date'] = resp['date']
        elsif container.length > 0 and object.length > 0 # object
          return md[:error] = "Object does not exist." if resp.code == 404
          return get_all_md.call() if all_md
          md['orig-filename'] = resp['x-object-meta-orig-filename']
          md['content-length'] = resp['content-length']
          md['last-modified'] = resp['last-modified']
          md['date'] = resp['date']
        end
        md
      rescue => ex
        @stdlog.debug(
          "#{MN}::  failed to list metadata for host = '#{@host}', \
port = '#{@nova_port}':")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end      
    end

    #
    # Queries with a GET operation for and then returns a list of containers.
    #

    def get_containers()
      begin
        uri = valid?() && URI.parse(@endpoint)
        http = valid?() && Net::HTTP.new(uri.host, uri.port)
        resp = valid?() && http.request_get(uri.path, {'X-Auth-Token' => @token})
=begin
        resp = valid?() && RestClient.get("#{@endpoint}", {'X-Auth-Token' => @token})
=end
      rescue => ex
        @stdlog.debug(
          "#{MN}::  failed to list containers for host = '#{@host}', \
port = '#{@nova_port}':")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end      
    end

    #
    # Queries with a GET operation for and then returns a list of containers.
    #

    def get_containers_plus()
      begin
        resp = valid?() && RestClient.get("#{@endpoint}",
          {'Accept' => 'application/json', 'X-Auth-Token' => @token})
        resp
      rescue => ex
        @stdlog.debug(
          "#{MN}::  failed to list containers for host = '#{@host}', \
port = '#{@nova_port}':")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end      
    end

    #
    # Queries with a GET operation for a list of objects.
    #
    # Arguments:
    #   container - the container - String

    def get_objects(container)
      raise(ArgumentError, "Expected String, not #{container.class.name}") \
        if !container.instance_of?(String)
      begin
        uri = valid?() && URI.parse(@endpoint)
        http = valid?() && Net::HTTP.new(uri.host, uri.port)
        resp = valid?() && http.request_get(uri.path + "/" + container,
          {'X-Auth-Token' => @token})
=begin
        resp = valid?() && RestClient.get("#{@endpoint}/#{container}",
          {'X-Auth-Token' => @token})
=end
      rescue => ex
        @stdlog.debug("#{MN}::  failed to list contents for container = \
'#{container}'")
        @stdlog.debug(
          "#{MN}::  failed to list objects for container = '#{@container}', \
host = '#{@host}', port = '#{@nova_port}':")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end      
    end

    #
    # Queries with a GET operation for and then returns a list of objects.
    #

    def get_objects_plus(container)
      begin
        resp = valid?() && RestClient.get("#{@endpoint}/#{container}",
          {'Accept' => 'application/json', 'X-Auth-Token' => @token})
        resp
      rescue => ex
        @stdlog.debug(
          "#{MN}::  failed to list objects for container = '#{@container}', \
host = '#{@host}', port = '#{@nova_port}':")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end      
    end

    #
    # Queries with a GET operation to retrieve an object.
    #
    # Arguments:
    #   container - the container - String
    #   object - the object - String
    #

    def get_object(container, object)
      raise(ArgumentError, "Expected String, not #{container.class.name}") \
        if !container.instance_of?(String)
      raise(ArgumentError, "Expected String, not #{object.class.name}") \
        if !object.instance_of?(String)
      begin
        headers = {'X-Auth-Token' => @token}
        resp = valid?() && RestClient.get("#{@endpoint}/#{container}/#{object}", headers)
      rescue => ex
        @stdlog.debug("#{MN}::  failed to retrieve object '#{object}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end      
    end

    #
    # Creates a container with a PUT operation, optionally including metadata.
    #
    # Arguments:
    #   container - the container - String
    #   metadata - the metadata - Hash
    #

    def put_container(container, metadata={})
      raise(ArgumentError, "Expected String, not #{container.class.name}") \
        if !container.instance_of?(String)
      raise(ArgumentError, "Expected Hash, not #{metadata.class.name}") \
        if !metadata.instance_of?(Hash)
      begin
        headers = Hash.new().merge(metadata).merge({'X-Auth-Token' => @token})
        #puts("put_container headers = #{headers}")
        resp = valid?() && RestClient.put("#{@endpoint}/#{container}", "no-payload", headers)
      rescue RestClient::ResourceNotFound => ex
        @stdlog.debug("#{MN}::  failed to create container = '#{container}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end      
    end

    #
    # Deletes a container with a DELETE operation.
    #
    # Arguments:
    #   container - the container - String
    #

    def delete_container(container)
      raise(ArgumentError, "Expected String, not #{container.class.name}") \
        if !container.instance_of?(String)
      #
      # RestClient fails to generate a response for HTTP codes, so do it manually:
      #
      resp = RestClientExceptionResponse.new
      begin
        # return a RestClient::Response on success:
        resp = valid?() && RestClient.delete("#{@endpoint}/#{container}",
          {'X-Auth-Token' => @token})
      rescue RestClient::ResourceNotFound => ex
        @stdlog.debug("#{MN}::  failed to delete container = '#{container}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        resp.body =
          "#{MN}::  failed to delete container = '#{container}': not found"
        resp.code = 404
        resp
      rescue RestClient::Conflict => ex
        @stdlog.debug("#{MN}::  failed to delete container = '#{container}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        resp.body =
          "#{MN}::  failed to delete container = '#{container}': conflict"
        resp.code = 409
        resp
      rescue => ex
        @stdlog.debug("#{MN}::  failed to delete container = '#{container}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        resp.body =
          "#{MN}::  failed to delete container = '#{container}': internal server error"
        resp.code = 500
        resp
      end      
    end

    #
    # Deletes containers with multiple DELETE operations.
    #
    # Arguments:
    #   containers - the containers - Array
    #

    def delete_containers(containers)
      raise(ArgumentError, "Expected Array, not #{container.class.name}") \
        if !containers.instance_of?(Array)
      deletions = {}
      begin
        containers.each do |container|
          deletions[container.to_sym] = delete_container(container)
        end
      rescue RestClient::ResourceNotFound => ex
        @stdlog.debug("#{MN}::  failed to delete containers '#{containers.inspect}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
      end      
      deletions
    end
=begin
    def delete_containers(containers)
      raise(ArgumentError, "Expected Array, not #{container.class.name}") \
        if !containers.instance_of?(Array)
      deletions = {}
      begin
        containers.each do |container|
          deletions[container.to_sym] = valid?() && RestClient.delete("#{@endpoint}/#{container}",
            {'X-Auth-Token' => @token})
        end
      rescue RestClient::ResourceNotFound => ex
        @stdlog.debug("#{MN}::  failed to delete containers '#{containers.inspect}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
      end      
      deletions
    end
=end

    #
    # Deletes an object with a DELETE operation.
    #
    # Arguments:
    #   container - the container - String
    #   object - the object - String
    #

    def delete_object(container, object)
      raise(ArgumentError, "Expected String, not #{container.class.name}") \
        if !container.instance_of?(String)
      raise(ArgumentError, "Expected String, not #{object.class.name}") \
        if !object.instance_of?(String)
      begin
        resp = valid?() && RestClient.delete("#{@endpoint}/#{container}/#{object}",
          {'X-Auth-Token' => @token})
      rescue RestClient::ResourceNotFound => ex
        @stdlog.debug("#{MN}::  failed to delete object = '#{object}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end      
    end

    #
    # Deletes objects with multiple DELETE operations.
    #
    # Arguments:
    #   container - the container - String
    #   objects - the objects - Array
    #

    def delete_objects(container, objects)
      raise(ArgumentError, "Expected String, not #{container.class.name}") \
        if !container.instance_of?(String)
      raise(ArgumentError, "Expected Array, not #{objects.class.name}") \
        if !objects.instance_of?(Array)
      deletions = {}
      begin
        objects.each do |object|
          deletions[object.to_sym] = valid?() &&
              RestClient.delete("#{@endpoint}/#{container}/#{object}",
            {'X-Auth-Token' => @token})
        end
      rescue RestClient::ResourceNotFound => ex
        @stdlog.debug("#{MN}::  failed to delete objects '#{objects.inspect}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
      end      
      deletions
    end

    #
    # Creates/stores an object with a PUT operation.
    #
    # Arguments:
    #   filespec - the filespec - String
    #   container - the container - String
    #   object - the object - String
    #   metadata - the metadata - Hash
    #

    def put_object(filespec, container, object, metadata={})
      #puts(filespec, container, object, metadata)
      raise(ArgumentError, "Expected String, not #{filespec.class.name}") \
        if !filespec.instance_of?(String)
      raise(ArgumentError, "Expected String, not #{container.class.name}") \
        if !container.instance_of?(String)
      raise(ArgumentError, "Expected String, not #{object.class.name}") \
        if !object.instance_of?(String)
      raise(ArgumentError, "Expected Hash, not #{metadata.class.name}") \
        if !metadata.instance_of?(Hash)
      begin
        #headers = {'X-Auth-Token' => @token, "Transfer-Encoding" => "chunked"}
        headers = {'X-Auth-Token' => @token}
        #headers['Content-Length'] = File.size(filespec).to_s
        headers.merge!(metadata)
        if headers['Destination']
          @stdlog.debug("#{MN}::  server-side object copy:")
          @stdlog.debug("#{MN}::  'Destination' = '#{headers['Destination']}'")
          #@stdlog.debug("#{MN}::  'Content-Length' = '#{headers['Content-Length']}'")
          @stdlog.debug("#{MN}::  source = '#{@endpoint}/#{container}/#{object}'")
          @stdlog.debug("#{MN}::  target = '#{@endpoint}#{headers['Destination']}'")
=begin
          resp = valid?() && RestClient.put("#{@endpoint}/#{container}/#{object}",
            File.read(filespec), headers)
=end
          http = Net::HTTP.new(@uri.host, @uri.port)
          source_path = "#{@path}/#{container}/#{object}"
          #puts("source_path = '#{source_path}'")
          resp = valid?() && http.copy(source_path, headers)
        else
          @stdlog.debug("#{MN}::  upload to: source = '#{object}', \
target = '#{object}'")
          headers.merge!({"Transfer-Encoding" => "chunked"})
          resp = valid?() && RestClient.put("#{@endpoint}/#{container}/#{object}",
            #File.read(filespec), headers)
            File.new(filespec, 'rb'), headers)
        end
      #rescue RestClient::ResourceNotFound => ex
      rescue => ex
        @stdlog.debug("#{MN}::  failed to create object = '#{object}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end      
    end

    #
    # Adds/stores object metadata with a POST operation, overriding existing
    # metadata.
    #
    # Arguments:
    #   container - the container - String
    #   object - the object - String
    #   metadata - the metadata - Hash
    #

    def post_object_metadata(container, object, metadata={})
      raise(ArgumentError, "Expected String, not #{container.class.name}") \
        if !container.instance_of?(String)
      raise(ArgumentError, "Expected String, not #{object.class.name}") \
        if !object.instance_of?(String)
      raise(ArgumentError, "Expected Hash, not #{metadata.class.name}") \
        if !metadata.instance_of?(Hash)
      begin
        headers = {'X-Auth-Token' => @token}
        headers.merge!(metadata)
        #puts("put_object headers = #{headers}")
        resp = valid?() && RestClient.post("#{@endpoint}/#{container}/#{object}", nil, headers)
      rescue RestClient::ResourceNotFound => ex
        @stdlog.debug("#{MN}::  failed to update object metadata = '#{object}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end      
    end

    #
    # Performs a HEAD operation to determine whether or not a container is empty.
    #
    # Arguments:
    #   container - the container - String
    #

    def get_object_count(container)
      raise(ArgumentError, "Expected String, not #{container.class.name}") \
        if !container.instance_of?(String)
      begin
        headers = {'X-Auth-Token' => @token}
        resp = valid?() && RestClient.head("#{@endpoint}/#{container}", headers)
        resp.headers[:x_container_object_count]
      rescue RestClient::ResourceNotFound => ex
        @stdlog.debug("#{MN}::  failed to obtain object count for '#{container}'")
        @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
        nil
      end      
    end
  end

#  SWIFT = SwiftProvider.new

  #############################################################################

  #
  # Executes swift-related operations.
  #
  # Arguments:
  #   command - the command - String
  #

  def swift_execute(command)
    begin
      %x[#{command}]
    rescue => ex
      @stdlog.debug("#{MN}::  failed to execute command '#{command}':")
      @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
    end
  end
end
