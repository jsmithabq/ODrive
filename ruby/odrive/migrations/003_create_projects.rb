
#
# Note: With Sqlite, :primary_key attribute does not imply NOT NULL
#

Class.new(Sequel::Migration) do
  def up
    create_table(:projects) do
      String :projectid, :primary_key => true, :null => false
      String :description, :null => false
    end
  end
  
  def down
    drop_table(:projects)
  end
end
