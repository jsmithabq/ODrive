
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
    if !(File.exists?(user_store) && !File.zero?(user_store))
      warn("#{MN}::  user database does not exist; creating '#{user_store}'.")
      aes = UserDBUtil::AESEncryptinator.new()
      db.create_table :users do
        String :userid, :primary_key => true, :null => false
        String :password, :null => false
        String :name, :null => false
        String :password_hint, :null => false, :default => "(none)"
        TrueClass :password_stale, :default => true
        String :style, :null => false, :default => "default"
        String :cloud_host, :null => false, :default => "(no cloud host)"
        String :cloud_tenant, :null => false, :default => "(no cloud tenant)"
        String :cloud_user, :null => false, :default => "(no cloud user)"
        String :cloud_password, :null => false, :default => aes.encrypt("(no cloud password)")
      end
    end
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
