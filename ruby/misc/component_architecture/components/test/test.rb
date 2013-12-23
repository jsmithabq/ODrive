#
# == Summary
#
# Defines a test component's routes for ODriveApp.  This test uses the
# standard <i>views</i> location.
#

class ODriveApp < Sinatra::Base

  get '/test' do
    @output = 'This is a test.  This is only a test!'
    
    haml :generic
  end
end
