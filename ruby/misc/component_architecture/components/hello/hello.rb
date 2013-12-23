#
# == Summary
#
# Defines a test component's routes for ODriveApp.  This test uses an
# alternate <i>views</i> location by calling <tt>component_haml()</tt> instead
# of <tt>haml()</tt>.
#

class ODriveApp < Sinatra::Base

  get '/hello' do
    @output = 'Hello, world!'
    
    component_haml "hello/views/hello".to_sym
  end
end
