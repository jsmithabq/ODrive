
#
# Note: With Sqlite, :primary_key attribute does not imply NOT NULL
#

Class.new(Sequel::Migration) do
  def up
    create_table(:schedules) do
      String :scheduleid, :primary_key => true, :null => false
      String :description, :null => false
      foreign_key :jobid, :jobs, :null => true
      foreign_key :projectid, :projects, :null => true
    end
  end
  
  def down
    drop_table(:schedules)
  end
end
