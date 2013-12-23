
#
# == Summary
#
# SqliteConnection implements connection handling for a SQLite embedded database.
#

require 'sequel'

#
# Provides basic connectivity to a SQLite database.
#
  
class SqliteConnection
  attr_reader :connection, :location

  #
  # Instantiates a database connection object.
  #
  # Arguments:
  #   location - the database path/file specification - String
  #
  
  def initialize(location)
    @location = location
    @connection = nil
  end
  
  #
  # Connect to the database.
  #
  
  def connect
    @connection = Sequel.sqlite(location)
  end
  
  #
  # Disconnect from the database.
  #
  
  def disconnect
    if @connection
      @connection.disconnect
      @connection = nil
    end
  end
end
