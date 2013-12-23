#!/usr/bin/env ruby

#
# Visit:  http://localhost:7000/
# Visit:  http://localhost:7000/index.frown
# Visit:  http://localhost:7000/index.smile
# Visit:  http://localhost:7000/.frown
# Visit:  http://localhost:7000/.smile
#

require 'ramaze'

class Smiley < Ramaze::Controller
  map '/'
  layout :face
  provide :frown, :engine => :Etanni
  provide :smile, :engine => :Etanni
  
  def index
    'Hello!'
  end
end

Ramaze.start
