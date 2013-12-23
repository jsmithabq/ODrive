
#
# Note: With Sqlite, :primary_key attribute does not imply NOT NULL
#

Class.new(Sequel::Migration) do
  def up
    create_table(:roles_users) do
      foreign_key :roleid, :roles
      foreign_key :userid, :users
      primary_key [:roleid, :userid]
      index [:roleid, :userid], :unique => true
    end
    DB[:roles_users].insert(:roleid => 'admin', :userid => 'admin')
    DB[:roles_users].insert(:roleid => 'analyst', :userid => 'aeinstein')
    DB[:roles_users].insert(:roleid => 'test', :userid => 'testuser')
  end
  
  def down
    drop_table(:roles_users)
  end
end
