
#
# == Summary
#
# UserModels interrogates the user database and creates model classes for each
# user management-related table.
#

require 'sequel'
require 'sqlite_connection.rb'
require 'odrive_config.rb'

include ODriveConfig # configuration support

#
# UserModels interrogates the user database and creates model classes for each
# user management-related table.
#

module UserModels
  MN = UserModels.name

  user_store = get_config_value(:user_store, USER_STORE_LOCATION)
  begin
    dbc = SqliteConnection.new(user_store)
    db = dbc.connect
  rescue => ex
    warn("#{MN}::  failed to connect to database '#{user_store}'.")
  end

  db.tables.each do |table|
    next if table == :schema_info
    names = table.to_s.split('_')
    class_name = ""
    names.each do |name|
      if name.end_with?("ses")  # not foolproof!
        name.chomp!("es")
      elsif name.end_with?("s") # not foolproof!
        name.chomp!("s")
      end
      class_name << name.capitalize()
    end
    c = Class.new(Sequel::Model) {}
    c.set_dataset(table)
    eval("#{class_name} = c")
  end

  begin
    dbc.disconnect
  rescue => ex
    error("#{MN}::  failed to disconnect from database '#{user_store}'.")
  end
end
