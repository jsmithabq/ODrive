
#
# == Summary
#
# Defines filters for all routes for ODriveApp.
#

class ODriveApp < Sinatra::Base
  #
  # Filter trailing slashes
  #

  before do
    #@stdlog.debug("#{CN}::  request.path_info = #{request.path_info}")
    request.path_info.chomp!('/') unless request.path_info.length == 1
    #@stdlog.debug("#{CN}::  request.path_info = #{request.path_info}")
  end
end
