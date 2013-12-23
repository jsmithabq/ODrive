
require 'base64'

#
# Note: With Sqlite, :primary_key attribute does not imply NOT NULL
#

Class.new(Sequel::Migration) do
  def up
    create_table(:users) do
      #primary_key :id
      String :userid, :primary_key => true, :null => false
      String :password, :null => false
      String :name, :null => false
      String :password_hint, :null => false, :default => "(none)"
      TrueClass :password_stale, :default => true
    end
    DB[:users].insert(:userid => "admin", :password => Base64.encode64("admin").chomp,
      :name => "Administrator The Great", :password_stale => false)
    DB[:users].insert(:userid => "jdoe", :password => Base64.encode64("headlights").chomp,
      :name => "Jane Doe", :password_stale => false)
    DB[:users].insert(:userid => "jblow", :password => Base64.encode64("windycity").chomp,
      :name => "Joe Blow", :password_stale => false)
    DB[:users].insert(:userid => "aeinstein", :password => Base64.encode64("relativity").chomp,
      :name => "Albert Einstein", :password_stale => false)
    DB[:users].insert(:userid => "tthumb", :password => Base64.encode64("allthumbs").chomp,
      :name => "Tom Thumb", :password_stale => false)
    DB[:users].insert(:userid => "marie", :password => Base64.encode64("layercake").chomp,
      :name => "Marie Antionette", :password_stale => false)
    DB[:users].insert(:userid => "jarc", :password => Base64.encode64("orleans").chomp,
      :name => "Joan O. Arc", :password_stale => false)
    DB[:users].insert(:userid => "testuser", :password => Base64.encode64("testy").chomp,
      :name => "Test E. User", :password_stale => false)
  end
  
  def down
    drop_table(:users)
  end
end
