#
# URL:  http://localhost:9292/
# Cmd:  rackup1.8 lobster.ru
#

require 'rack'
require 'rack/lobster'

run Rack::Lobster.new
