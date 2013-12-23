
#
# Note: With Sqlite, :primary_key attribute does not imply NOT NULL
#

Class.new(Sequel::Migration) do
  def up
    create_table(:statuses) do
      primary_key :id
      String :status, :null => false
      foreign_key :jobid, :jobs, :null => false
    end
  end
  
  def down
    drop_table(:statuses)
  end
end
