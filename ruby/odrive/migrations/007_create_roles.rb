
#
# Note: With Sqlite, :primary_key attribute does not imply NOT NULL
#

Class.new(Sequel::Migration) do
  def up
    create_table(:roles) do
      String :roleid, :primary_key => true, :null => false
      String :description, :null => false
    end
    DB[:roles].insert(:roleid => 'admin',
      :description => 'Users with administrative privileges')
    DB[:roles].insert(:roleid => 'analyst',
      :description => 'Users with standard analyst privileges')
    DB[:roles].insert(:roleid => 'test',
      :description => 'Users with testing privileges')
  end
  
  def down
    drop_table(:roles)
  end
end
