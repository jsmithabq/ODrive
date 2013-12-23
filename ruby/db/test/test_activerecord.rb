#!/usr/bin/ruby

#
# Notes:  ActiveRecord is beneath '/usr/share/rails'
#
#ruby -I /usr/share/rails/activerecord/lib activerecord_test.rb
#ruby -I $ACTIVE_RECORD_HOME activerecord_test.rb
#

require 'activerecord'

ActiveRecord::Base.establish_connection :adapter => "sqlite3", :database => "duck.db"

class Duck < ActiveRecord::Base
  validates_length_of :name, :maximum => 6
end

duck = Duck.new
duck.name = "Donald"
duck.save
