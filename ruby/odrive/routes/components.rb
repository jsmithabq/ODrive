
#
# == Summary
#
# Defines component-based hooks for ODriveApp.
#

require 'restclient'
require 'stringio'

class ODriveApp < Sinatra::Base

  #
  # http://<host>:<port>/
  #
  
  get %r@#{ODRIVE_ROOT + "components"}#{ODRIVE_EXT}@ do
    content_type ODRIVE_FORMAT[get_content_type()]
    
    @stdlog.debug("ODriveApp::(/components)  request.url = #{request.url}.")
    @heading = "Active Components"
    path = Pathname.new(ODRIVE_COMPONENT_DIR)
    rr = ResponseRenderer.new(get_content_type())
    rr.append_class_start('components')
    if path.directory?
      count = 0
      path.entries.each do |entry|
        comp_path = path + entry
        if comp_path.parent.realpath == path.realpath
          count += 1
          rr.append_instance_start('component')
          rr.append_attr('name', entry.to_s, :string)
          rr.append_instance_end()
        end
      end
    end
    rr.append_instance_start('summary')
    rr.append_attr('number-of-components', count, :integer)
    rr.append_instance_end()
    rr.append_class_end()
    @stdlog.debug("ODriveApp::  number of components = #{count}.")
    @output = rr.data

    handle_response(get_content_type(), :generic)
  end
end
