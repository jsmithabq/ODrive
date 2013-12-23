#!/usr/bin/env ruby

#
# Visit:  http://localhost:7000/concat/A/B
# Visit:  http://localhost:7000/concat/A/B?who=abby
#

require 'ramaze'

class MainController < Ramaze::Controller
  def concat(first, second)
    %Q(
First two arguments concatenated = '#{first + second}',
GET variable 'who' = '#{request['who']}'
    )
  end
end

Ramaze.start
