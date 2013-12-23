#
# URL:  http://localhost:6799/
# Cmd:  rackup1.8 odrive.ru
#

#run ODriveApp.new

# Or:

require 'odrive.rb'
require 'user_manager.rb' # must be after 'odrive.rb'
require 'resource_manager.rb' # must be after 'odrive.rb'

# And, to run with WEBrick:

#ODriveApp.run!

#Or, to run with Thin:

#Rack::Handler::Thin.run(ODriveApp.new, :Port => 9000)
Rack::Handler::Thin.run(ODriveApp.new, :Port => 8080)
