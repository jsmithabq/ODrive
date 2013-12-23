#!/usr/bin/env ruby

#
# Visit:  http://localhost:7000/
#

require 'ramaze'

class HelloController < Ramaze::Controller
  layout :default
  
  def index
    'Hello, world!'
  end
end

Ramaze.start
