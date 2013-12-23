
#
# == Summary
#
# Defines conditional methods for ODriveApp related to authentication,
# authentication status, and roles.
#
# ODrive must provide multiple roles to support multiple distributed
# storage back-ends, some of which are not cloud-related.
#

class ODriveApp < Sinatra::Base
  register do
    def authenticated(type)
      condition do
        redirect '/login' unless send("is_#{type}?")
      end
    end
    
    def status(type)
      condition do
        redirect '/password' if send("is_#{type}?")
      end
    end
        
    def client_role(type)
      condition do
        redirect '/client-restriction' unless send("is_#{type}?")
      end
    end
        
    def session_role(type)
      condition do
        redirect '/session-restriction' unless send("is_#{type}?")
      end
    end
        
    def authorized_role(type)
      condition do
        redirect '/authorized-restriction' unless send("is_#{type}?")
      end
    end
        
    def role(type)
      condition do
        redirect '/access-restriction' unless send("is_#{type}?")
      end
    end
  end
end
