require 'odrive_down.rb'

# And, to run with WEBrick:

#ODriveAppDown.run!

#Or, to run with Thin:

#Rack::Handler::WEBrick.run(ODriveAppDown.new, :Port => 9000)
Rack::Handler::Thin.run(ODriveAppDown.new, :Port => 9000)
