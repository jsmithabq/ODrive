#!/usr/bin/env ruby

#
# Visit:  http://localhost:7000/
# Visit:  http://localhost:7000/?user=admin
#

require 'ramaze'

class RestrictedArea < Ramaze::Controller
  def index
    '<p>Private stuff goes here.</p>'
  end
  
  before_all do
    unless session[:vip]
      flash[:error] = 'Access denied'
      redirect_referer
    end
  end
end

class NormalArea < Ramaze::Controller
  map '/'
  
  def index
    return if session[:vip]
    session[:vip] = request['user'] == 'admin'
    %q(
<p>Content goes here.</p>
#{flashbox}
#{a('restricted area', RestrictedArea.route)}
    )
  end
end

Ramaze.start
