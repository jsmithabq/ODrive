
#
# == Summary
#
# Defines last-chance routes for ODriveApp.
#

class ODriveApp < Sinatra::Base
  #
  # http://<host>:<port>/*  # any remaining undefined routes
  #

  [ODRIVE_UNKNOWN,
   ODRIVE_PREFIX + ODRIVE_UNKNOWN
  ].each do |path|
    get path do
      content_type ODRIVE_FORMAT[get_content_type()]
  
      @output = "The requested resource is invalid: \'#{request.url}\'."
      haml :unknown
    end
  end
end
