#!/usr/bin/env ruby

#
# = Summary
#
# user_db_create_db creates a local store for managing users.
#
# This script should be executed relative to the app server's working directory.
#

require 'sequel'
require 'sqlite_connection.rb'
require 'user_db_util.rb'

include UserDBUtil

if ARGV.length == 1 && ["-h", "-help", "--help"].include?(ARGV[0])
  puts
  puts("usage: ruby user_db_create_db.rb")
  exit(0)
end
begin
  status = 0
  aes = UserDBUtil::AESEncryptinator.new()
  dbc = SqliteConnection.new('../store/ODriveUserManagement-test.db')
  db = dbc.connect
  puts("Preparing to create database -- this will destroy any existing database!!")
  print("Create database: [yes/no] ")
  final_answer = gets().chomp
  puts("You responded: '#{final_answer}'")
  if final_answer == "yes"
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
    db[:users].insert(:userid => "admin", :password => encrypt_one_way("admin"),
      :name => "Administrator The Great", :password_stale => false)
    db[:users].insert(:userid => "jdoe", :password => encrypt_one_way("headlights"),
      :name => "Jane Doe", :password_stale => false)
    db[:users].insert(:userid => "jblow", :password => encrypt_one_way("windycity"),
      :name => "Joe Blow", :password_stale => false)
    db[:users].insert(:userid => "aeinstein", :password => encrypt_one_way("relativity"),
      :name => "Albert Einstein", :password_stale => false)
    db[:users].insert(:userid => "tthumb", :password => encrypt_one_way("allthumbs"),
      :name => "Tom Thumb", :password_stale => false)
    db[:users].insert(:userid => "marie", :password => encrypt_one_way("layercake"),
      :name => "Marie Antionette", :password_stale => false)
    db[:users].insert(:userid => "jarc", :password => encrypt_one_way("orleans"),
      :name => "Joan O. Arc", :password_stale => false)
    db[:users].insert(:userid => "testuser", :password => encrypt_one_way("testy"),
      :name => "Test E. User", :password_stale => false)
    puts("Database created successfully.")
  else
    puts("Database creation abandoned.")
  end
rescue Sequel::DatabaseError => e
  puts('Database error:')
  puts(e)
  status = -1
ensure
  dbc.disconnect if dbc
end
exit(status)
