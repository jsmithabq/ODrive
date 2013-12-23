
#
# Note: With Sqlite, :primary_key attribute does not imply NOT NULL
#

Class.new(Sequel::Migration) do
  def up
    create_table(:projects_jobs) do
      foreign_key :projectid, :projects
      foreign_key :jobid, :jobs
      index [:projectid, :jobid], :unique => true
    end
  end
  
  def down
    drop_table(:projects_jobs)
  end
end
