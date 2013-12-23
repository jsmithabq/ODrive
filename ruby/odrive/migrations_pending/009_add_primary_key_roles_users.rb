
#
# Note: With Sqlite, :primary_key attribute does not imply NOT NULL
#

Class.new(Sequel::Migration) do
  def up
    alter_table(:roles_users) do
      add_primary_key [:roleid, :userid]
    end
  end
  
  def down
  end
end
