#!/usr/bin/env ruby

#
# = Summary
#
# user_db_create_db creates a local store for managing users.
#
# This script should be executed relative to the app server's working directory.
#

require 'base64'
require 'sequel'
require 'sqlite_connection.rb'

if ARGV.length == 1 && ["-h", "-help", "--help"].include?(ARGV[0])
  puts
  puts("usage: ruby user_db_create_db.rb")
  exit(0)
end
begin
  status = 0
  dbc = SqliteConnection.new('../store/ODriveUserManagement.db')
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
      String :cloud_password, :null => false, :default => "(no cloud password)"
    end
    db[:users].insert(:userid => "admin", :password => Base64.encode64("admin").chomp,
      :name => "Administrator The Great", :password_stale => false)
    db[:users].insert(:userid => "jdoe", :password => Base64.encode64("headlights").chomp,
      :name => "Jane Doe", :password_stale => false)
    db[:users].insert(:userid => "jblow", :password => Base64.encode64("windycity").chomp,
      :name => "Joe Blow", :password_stale => false)
    db[:users].insert(:userid => "aeinstein", :password => Base64.encode64("relativity").chomp,
      :name => "Albert Einstein", :password_stale => false)
    db[:users].insert(:userid => "tthumb", :password => Base64.encode64("allthumbs").chomp,
      :name => "Tom Thumb", :password_stale => false)
    db[:users].insert(:userid => "marie", :password => Base64.encode64("layercake").chomp,
      :name => "Marie Antionette", :password_stale => false)
    db[:users].insert(:userid => "jarc", :password => Base64.encode64("orleans").chomp,
      :name => "Joan O. Arc", :password_stale => false)
    db[:users].insert(:userid => "testuser", :password => Base64.encode64("testy").chomp,
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
