
#
# == Summary
#
# PostgresqlConnection implements connection handling for a PostgreSQL database.
#

require 'sequel'

#
# Provides basic connectivity to a PostgreSQL database.
#
  
class PostgresqlConnection
  attr_reader :host, :database, :user, :password
  attr_reader :connection
  
  #
  # Instantiates a database connection object.
  #
  # Arguments:
  #   host - the database host - String
  #   database - the database name - String
  #   user - the database userid - String
  #   password - the database password - String
  #
  
  def initialize(host, database, user, password)
    @host, @database, @user, @password = host, database, user, password
    @connection = nil
  end
  
  #
  # Connect to the database.
  #
  
  def connect
    @connection = Sequel.postgres(:host => @host, :database => @database,
       :user => @user, :password => @password)
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
