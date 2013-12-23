#!/usr/bin/env ruby

#
# Visit:  http://localhost:7000/
#

require 'ramaze'

class HelloController < Ramaze::Controller
  map '/hello' # note no trailing slash, not significant with Ramaze
  
  def index
    'Hello, world!'
  end
end

class GoodbyeController < Ramaze::Controller
  map '/goodbye'
  
  def index
    'Goodbye, world!'
  end
end

class MainController < HelloController
end

Ramaze.start
