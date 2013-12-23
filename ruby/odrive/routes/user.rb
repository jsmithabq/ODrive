
#
# == Summary
#
# Defines non-session, user-related routes for ODriveApp.
#

class ODriveApp < Sinatra::Base
  #
  # http://<host>:<port>/<prefix>/users/<userid>
  # For now, authenticated users can list users.
  #

  get %r@#{ODRIVE_PREFIX + "/users/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@, :authenticated => :user do
    content_type ODRIVE_FORMAT[get_content_type()]
    
    @stdlog.debug("#{CN}::(/<prefix>/users/<userid>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    userid = params[:captures][0]
    userid = cleanse_extension(userid)
    list_users(LIST_ONE_USER, request, params, table=false, [userid])
  end

#  get ODRIVE_PREFIX + '/users/:userid', :authenticated => :user do
#    new_value = cleanse_extension(params[:userid])
#    params.delete(:userid)
#    params[:userid] = new_value
#    list_users(LIST_ONE_USER, params, [params[:userid]])
#  end

  #
  # http://<host>:<port>/<prefix>/users
  # For now, authenticated users can list users.
  #

  get %r@#{ODRIVE_PREFIX + '/users'}#{ODRIVE_EXT}@, :authenticated => :user do
    list_users(LIST_MULTIPLE_USERS, request, params, table=false)
  end

  #
  # http://<host>:<port>/users
  # For now, authenticated users can list users.
  #

  get %r@#{'/users'}#{ODRIVE_EXT}@, :authenticated => :user do
    list_users(LIST_MULTIPLE_USERS, request, params, table=true)
  end
end
