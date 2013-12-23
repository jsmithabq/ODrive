
#
# == Summary
#
# Defines helper methods and related filters for ODriveApp.
#

class ODriveApp < Sinatra::Base
  helpers do
    #
    # Supports client connections to RESTful services.
    #
    
    def is_user_auth_basic?
      UserManager.is_user_auth_basic?(request)
    end
            
    #
    # Identifies either client- and (web) session-based users.
    #
    
    def is_user?
      return true if is_user_auth_basic?()
      #userid && UserManager.exists?(userid)
      login_time = session[:login_time]
      session[:user_id] && UserManager.exists?(session[:user_id]) &&
        login_time && login_time != "nil" &&
        login_time > ResourceManager.get_parameter(:app_start_time).to_s
    end
            
    #
    # Identifies client users.
    #

    def is_client_user?
      !is_session_user?() && is_user_auth_basic?()
    end
        
    #
    # Identifies (web) session users requiring resource manager configuration.
    #

    def is_session_user?
      is_user? && session[:user_id] && UserManager.cloud_session?(session[:user_id])
    end
        
    #
    # Identifies authorized users, i.e., authorized for accessing storage services.
    #
    # is_user?() is not tested here, in order to separate the login process/redirect
    # from authorization-related checks.
    #

    def is_authorized_user?
      is_session_user?() || is_client_user?()
    end
        
    #
    # Identifies admin users with respect to ODrive only, e.g., listing user info.
    #

    def is_admin?
      is_user? && session[:user_id] && session[:user_id] == 'admin'
    end
        
    #
    # Identifies users who haven't set a password.
    #

    def is_stale?
      is_user? && session[:user_id] && UserManager.stale?(session[:user_id])
    end
  end
  
  before do
    #@user = UserManager.exists?(session[:user_id])
  end
end
