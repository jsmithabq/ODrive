
#
# Note: With Sqlite, :primary_key attribute does not imply NOT NULL
#

Class.new(Sequel::Migration) do
  def up
    create_table(:jobs) do
      #primary_key :id
      String :jobid, :primary_key => true, :null => false
      String :description, :null => false
      String :userid, :null => false
      String :projectid, :null => true
    end
  end
  
  def down
    drop_table(:jobs)
  end
end
