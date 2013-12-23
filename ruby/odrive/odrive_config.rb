
#
# = Summary
#
# ODriveConfig handles start-up configuration data.
#
# CONFIG is initialized once and ODriveConfig provides a single top-level
# method, get_config_value(), for retrieving configuration values.  In
# addition, ODriveConfig provides the Configurator class so that an
# application component can instantiate new instances dynamically, each time
# rereading the configuration settings.
#
# ODriveConfig expects "YAML format" key-value pairs, e.g.,
#   cc_host : cloudhost.example.com
#   local_port : 6789
#   log_device : stdout
#   log_level : debug
#
# The default configuration file is located relative to the start-up directory:
# <tt>./odrive.config</tt>.

require 'fileutils'
require 'logger'
require 'ostruct'
require 'yaml'
require 'odrive_info.rb'

#
# ODriveConfig handles start-up configuration data.
# CONFIG is initialized once, but an application component can instantiate new
# Configurator instances dynamically, each time rereading the configuration
# settings.
#
# ODriveConfig expects "YAML format" key-value pairs, e.g.,
#   cc_host : cloudhost.example.com
#   local_port : 6789
#   log_device : stdout
#   log_level : debug
#
# The default configuration file is located relative to the start-up directory:
# <tt>./odrive.config</tt>.
#

module ODriveConfig
  MN = ODriveConfig.name

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
  
    def initialize(file=ODRIVE_CONFIG_FILE)
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
        @verbose = get_value(:verbose, 'false')
        #puts("@verbose = #{@verbose}, class = #{@verbose.class.name}")
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
    # Creates a logger based on the configuration settings from <tt>odrive.config</tt>.
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
  
  ODRIVE_CONFIG = Configurator.new
  ODRIVE_CONFIG.stdlog.debug("#{MN}::  configurator is '#{ODRIVE_CONFIG.class}'.")
  
  #
  # Gets the value associated with a configuration attribute--at the time of
  # the instantiation of the CONFIG instance of Configurator.
  #
  # Arguments:
  #   key - the configuration key - Symbol
  #   default - an optional default value, returned if the key is nil - String
  #
  
  def get_config_value(key, default=nil)
    ODRIVE_CONFIG.get_value(key, default)
  end
  
  #
  # Gets the current working directory for the application.
  #
  
  def get_cwd()
    FileUtils::pwd()
  end
end
