
#
# == Summary
#
# Defines object drive-related routes for ODriveApp.
#

require 'digest/md5'

class ODriveApp < Sinatra::Base

  #
  # get http://<host>:<port>/webupload/containers/<container>
  #

  get %r@#{"/webupload/containers/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[:html]

    @stdlog.debug(
      "#{CN}::  (GET /webupload/containers/<container>) \
request.url = #{request.url}.")
    @container_name = cleanse_extension(params[:captures][0])
    #puts("params = #{params.inspect}")

    haml :upload
  end

  #
  # get http://<host>:<port>/webcopy/containers/<container>/objects/<object>
  #

  get %r@#{"/webcopy/containers/#{ODRIVE_NAME}/objects/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[:html]

    @stdlog.debug(
      "#{CN}::  (GET /webcopy/containers/<container>/objects/<object>) \
request.url = #{request.url}.")
    @from_container_name = cleanse_extension(params[:captures][0])
    @from_object_name = params[:captures][1]
    #puts("params = #{params.inspect}")

    haml :copy
  end

  #
  # get http://<host>:<port>/webdelete/containers/<container>/objects/<object>
  #

  get %r@#{"/webdelete/containers/#{ODRIVE_NAME}/objects/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[:html]

    @stdlog.debug(
      "#{CN}::  (GET /webdelete/containers/<container>/objects/<object>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    container_name = cleanse_extension(params[:captures][0])
    #object_name = cleanse_extension(params[:captures][1])
    object_name = params[:captures][1]
    #puts("params = #{params.inspect}")
    @heading = "Container: #{container_name} Object: #{object_name}"
    rr = ResponseRenderer.new(:html)
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.delete_object(container_name, object_name)
    if !resp || resp.code == 404
      @stdlog.debug("#{CN}::  failed to delete object: #{object_name}.")
      rr.append_error("Failed to delete object: #{object_name}.")
      @output = rr.data
      handle_response(get_content_type(), :generic)
    else
      rr.append_class_attrs_start('DELETE', {:object => object_name}, table=true)
      rr.append_instance_start('response', table=true)
      rr.append_attr("code", resp.code, 'string', table=true)
      rr.append_attr("body", resp.body, 'string', table=true)
      rr.append_instance_end()
      rr.append_class_end()
      @urls = [
        {:url => "/web/containers/#{container_name}",
        :name => "Container #{container_name}"}
      ]
      @output = rr.data
      handle_response(get_content_type(), :genericaction)
    end
  end

  #
  # GET http://<host>:<port>/htmltable/containers/<container>
  #

  get %r@#{"/htmltable/containers/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /htmltable/containers/<container>) \
request.url = #{request.url}.")
    page, page_size = pagination(params)
    container_name = cleanse_extension(params[:captures][0])
    @heading = "Container:  #{container_name}"
    rr = ResponseRenderer.new(get_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.get_objects_plus(container_name)
    #puts(resp.inspect)
    if !resp
      @stdlog.debug("#{CN}::  unable to query for objects (authentication?).")
      rr.append_error("Unable to query for objects (authentication?).")
    else
      objects = JSON.load(resp)
      objects.each do |object|
        rr.append_attrs_as_table_row(object, ['name', 'bytes'])
      end
    end  

    @output = rr.data
    handle_response(get_content_type(), :generictable)
  end

  #
  # GET http://<host>:<port>/htmltable/containers
  #

  get %r@#{"/htmltable/containers"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /htmltable/containers) request.url = #{request.url}.")
    page, page_size = pagination(params)
    @heading = 'Containers'
    rr = ResponseRenderer.new(get_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.get_containers_plus()
    #puts(resp.inspect)
    if !resp
      @stdlog.debug("#{CN}::  unable to query for containers (authentication?).")
      rr.append_error("Unable to query for containers (authentication?).")
    else
      containers = JSON.load(resp)
      containers.each do |container|
        rr.append_attrs_as_table_row(container, ['name', 'count', 'bytes'])
      end
    end  

    @output = rr.data
    handle_response(get_content_type(), :generictable)
  end

  #
  # GET http://<host>:<port>/web/containers/<container>
  #

  get %r@#{"/web/containers/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /web/containers/<container>) request.url = #{request.url}.")
    page, page_size = pagination(params)
    @container_name = cleanse_extension(params[:captures][0])
    @heading = "Objects for Container:  <em>#{@container_name}</em>"
    rr = ResponseRenderer.new(get_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.get_objects_plus(@container_name)
    #puts(resp.inspect)
    if !resp
      @stdlog.debug("#{CN}::  unable to query for objects (authentication?).")
      rr.append_error("Unable to query for objects (authentication?).")
      @output = rr.data
      handle_response(get_content_type(), :generic)
    else
      @objects = JSON.load(resp)
      handle_response(get_content_type(), :objects) # just haml ???
   end
  end

  #
  # GET http://<host>:<port>/web/containers
  #

  get %r@#{"/web/containers"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /web/containers) request.url = #{request.url}.")
    page, page_size = pagination(params)
    @heading = 'Containers'
    rr = ResponseRenderer.new(get_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.get_containers_plus()
    #puts(resp.inspect)
    if !resp
      @stdlog.debug("#{CN}::  unable to query for containers (authentication?).")
      rr.append_error("Unable to query for containers (authentication?).")
      @output = rr.data
      handle_response(get_content_type(), :generic)
    else
      @containers = JSON.load(resp)
      handle_response(get_content_type(), :containers) # just haml ???
    end  

  end

  #
  # GET http://<host>:<port>/<prefix>/containers/<container>/objects/<object>/metadata
  #

  get %r@#{ODRIVE_PREFIX + "/containers/#{ODRIVE_NAME}/objects/#{ODRIVE_NAME}/metadata"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user  do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug(
      "#{CN}::  (GET /<prefix>/containers/<container>/objects/<object>/metadata) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    page, page_size = pagination(params)
    container_name = cleanse_extension(params[:captures][0])
    #object_name = cleanse_extension(params[:captures][1])
    object_name = params[:captures][1]
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    metadata = cloud && cloud.get_metadata(container_name, object_name, true)
    @heading = "Object Metadata: #{object_name}"
    rr = ResponseRenderer.new(get_content_type())
    if !metadata
      @stdlog.debug("#{CN}::  no object metadata available.")
      rr.append_error("No object metadata available.")
    else
      rr.append_class_attrs_start('metadata',
        {:host => cloud.host, :container => container_name, :object => object_name},
        get_content_type() == :html)
      metadata.each do |k,v|
        rr.append_instance_start('metadatum', get_content_type() == :html)
        rr.append_attr(k, v, 'string', get_content_type() == :html)
        rr.append_instance_end()
       end
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/containers/<container>/objects/<object>/metadata
  #

  get %r@#{"/containers/#{ODRIVE_NAME}/objects/#{ODRIVE_NAME}/metadata"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug(
      "#{CN}::  (GET /containers/<container>/objects/<object>/metadata) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    page, page_size = pagination(params)
    container_name = cleanse_extension(params[:captures][0])
    #object_name = cleanse_extension(params[:captures][1])
    object_name = params[:captures][1]
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    metadata = cloud && cloud.get_metadata(container_name, object_name, true)
    @heading = "Object Metadata: #{object_name}"
    rr = ResponseRenderer.new(get_content_type())
    if !metadata
      @stdlog.debug("#{CN}::  no object metadata available.")
      rr.append_error("No object metadata available.")
    else
      rr.append_class_attrs_start('metadata',
        {:host => cloud.host, :container => container_name, :object => object_name},
        get_content_type() == :html)
      metadata.each do |k,v|
        rr.append_instance_start('metadatum', get_content_type() == :html)
        rr.append_attr(k, v, 'string', get_content_type() == :html)
        rr.append_instance_end()
       end
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/<prefix>/containers/<container>/metadata
  #

  get %r@#{ODRIVE_PREFIX + "/containers/#{ODRIVE_NAME}/metadata"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /<prefix>/containers/<container>/metadata) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    page, page_size = pagination(params)
    container_name = params[:captures][0]
    container_name = cleanse_extension(container_name)
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    metadata = cloud && cloud.get_metadata(container_name, "", true)
    @heading = "Container Metadata: #{container_name}"
    rr = ResponseRenderer.new(get_content_type())
    if !metadata
      @stdlog.debug("#{CN}::  no container metadata available.")
      rr.append_error("No container metadata available.")
    else
      rr.append_class_attrs_start('metadata',
        {:host => cloud.host, :container => container_name}, get_content_type() == :html)
      metadata.each do |k,v|
        rr.append_instance_start('metadatum', get_content_type() == :html)
        rr.append_attr(k, v, 'string', get_content_type() == :html)
        rr.append_instance_end()
       end
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/containers/<container>/metadata
  #

  get %r@#{"/containers/#{ODRIVE_NAME}/metadata"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /containers/<container>/metadata) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    page, page_size = pagination(params)
    container_name = params[:captures][0]
    container_name = cleanse_extension(container_name)
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    metadata = cloud && cloud.get_metadata(container_name, "", true)
    @heading = "Container Metadata: #{container_name}"
    rr = ResponseRenderer.new(get_content_type())
    if !metadata
      @stdlog.debug("#{CN}::  no container metadata available.")
      rr.append_error("No container metadata available.")
    else
      rr.append_class_attrs_start('metadata',
        {:host => cloud.host, :container => container_name}, get_content_type() == :html)
      metadata.each do |k,v|
        rr.append_instance_start('metadatum', get_content_type() == :html)
        rr.append_attr(k, v, 'string', get_content_type() == :html)
        rr.append_instance_end()
       end
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/<prefix>/containers/<container>/count
  #

  get %r@#{ODRIVE_PREFIX + "/containers/#{ODRIVE_NAME}/count"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /<prefix>/containers/<container>/count) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    page, page_size = pagination(params)
    container_name = params[:captures][0]
    container_name = cleanse_extension(container_name)
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    count = cloud && cloud.get_object_count(container_name)
    @heading = "Container Object Count: #{container_name}"
    rr = ResponseRenderer.new(get_content_type())
    if !count
      @stdlog.debug("#{CN}::  no container object count available.")
      rr.append_error("No container object count available.")
    else
      rr.append_class_attrs_start('counts',
        {:host => cloud.host}, get_content_type() == :html)
      rr.append_instance_attrs_start('count',
        {:container => container_name}, get_content_type() == :html)
      rr.append_attr("objects", count, 'string', get_content_type() == :html)
      rr.append_instance_end()
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/containers/<container>/count
  #

  get %r@#{"/containers/#{ODRIVE_NAME}/count"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /containers/<container>/count) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    page, page_size = pagination(params)
    container_name = params[:captures][0]
    container_name = cleanse_extension(container_name)
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    count = cloud && cloud.get_object_count(container_name)
    @heading = "Container Object Count: #{container_name}"
    rr = ResponseRenderer.new(get_content_type())
    if !count
      @stdlog.debug("#{CN}::  no container object count available.")
      rr.append_error("No container object count available.")
    else
      rr.append_class_attrs_start('counts',
        {:host => cloud.host}, get_content_type() == :html)
      rr.append_instance_attrs_start('count',
        {:container => container_name}, get_content_type() == :html)
      rr.append_attr("objects", count, 'string', get_content_type() == :html)
      rr.append_instance_end()
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/<prefix>/metadata
  #

  get %r@#{ODRIVE_PREFIX + "/metadata"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /<prefix>/metadata) \
request.url = #{request.url}.")
    page, page_size = pagination(params)
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    metadata = cloud && cloud.get_metadata("", "", true)
    @heading = "Account (Tenant) Metadata"
    rr = ResponseRenderer.new(get_content_type())
    if !metadata
      @stdlog.debug("#{CN}::  no account (tenant) metadata available.")
      rr.append_error("No account (tenant) metadata.")
    else
      rr.append_class_attrs_start('metadata',
        {:host => cloud.host, :account => cloud.account}, get_content_type() == :html)
      metadata.each do |k,v|
        rr.append_instance_start('metadatum', get_content_type() == :html)
        rr.append_attr(k, v, 'string', get_content_type() == :html)
        rr.append_instance_end()
       end
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/metadata
  #

  get %r@#{"/metadata"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /metadata) request.url = #{request.url}.")
    page, page_size = pagination(params)
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    metadata = cloud && cloud.get_metadata()
    @heading = "Account (Tenant) Metadata"
    rr = ResponseRenderer.new(get_content_type())
    if !metadata
      @stdlog.debug("#{CN}::  no account (tenant) metadata available.")
      rr.append_error("No account (tenant) metadata.")
    else
      rr.append_class_attrs_start('metadata',
        {:host => cloud.host, :account => cloud.account}, get_content_type() == :html)
      metadata.each do |k,v|
        rr.append_instance_start('metadatum', get_content_type() == :html)
        rr.append_attr(k, v, 'string', get_content_type() == :html)
        rr.append_instance_end()
       end
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/<prefix>/containers
  #

  get %r@#{ODRIVE_PREFIX + "/containers"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /<prefix>/containers) \
request.url = #{request.url}.")
    page, page_size = pagination(params)
    #puts("params = #{params.inspect}")
    attrs = ['name', 'count', 'bytes']
    if params[:attrs]
      temp = cleanse_extension(params[:attrs]).split('|')
      #puts("temp = #{temp.inspect}")
      attrs = temp if temp.length > 0
    end
    @heading = 'Containers'
    rr = ResponseRenderer.new(get_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.get_containers_plus()
    #puts(resp.inspect)
    if !resp
      @stdlog.debug("#{CN}::  unable to query for containers (authentication?).")
      rr.append_error("Unable to query for containers (authentication?).")
    else
      containers = JSON.load(resp)
      rr.append_class_attrs_start('containers',
        {:host => cloud.host, :count => containers.length}, get_content_type() == :html)
      containers.each do |container|
        rr.append_instance_start('container', get_content_type() == :html)
        rr.append_attrs_as_row(container, attrs, get_content_type() == :html)
        rr.append_instance_end()
      end
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/containers
  #

  get %r@#{"/containers"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /containers) request.url = #{request.url}.")
    page, page_size = pagination(params)
    #puts("params = #{params.inspect}")
    attrs = ['name', 'count', 'bytes']
    if params[:attrs]
      temp = cleanse_extension(params[:attrs]).split('|')
      #puts("temp = #{temp.inspect}")
      attrs = temp if temp.length > 0
    end
    @heading = 'Containers'
    rr = ResponseRenderer.new(get_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.get_containers_plus()
    #puts(resp.inspect)
    if !resp
      @stdlog.debug("#{CN}::  unable to query for containers (authentication?).")
      rr.append_error("Unable to query for containers (authentication?).")
    else
      containers = JSON.load(resp)
      rr.append_class_attrs_start('containers',
        {:host => cloud.host, :count => containers.length}, get_content_type() == :html)
      containers.each do |container|
        rr.append_instance_start('container', get_content_type() == :html)
        rr.append_attrs_as_row(container, attrs, get_content_type() == :html)
        rr.append_instance_end()
      end
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/<prefix>/containers/<container>/objects
  #

  get %r@#{ODRIVE_PREFIX + "/containers/#{ODRIVE_NAME}/objects"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /<prefix>/containers/<container>/objects) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    container_name = cleanse_extension(params[:captures][0])
    redirect ODRIVE_PREFIX + "/containers/#{container_name}#{params[:captures][1]}"
  end

  #
  # GET http://<host>:<port>/containers/<container>/objects
  #

  get %r@#{"/containers/#{ODRIVE_NAME}/objects"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /containers/<container>/objects) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    container_name = cleanse_extension(params[:captures][0])
    redirect "/containers/#{container_name}#{params[:captures][1]}"
  end

  #
  # GET http://<host>:<port>/<prefix>/containers/<container>
  #

  get %r@#{ODRIVE_PREFIX + "/containers/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /<prefix>/containers/<container>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    container_name = cleanse_extension(params[:captures][0])
    #puts("params = #{params.inspect}")
    attrs = ['name', 'bytes']
    if params[:attrs]
      temp = cleanse_extension(params[:attrs]).split('|')
      #puts("temp = #{temp.inspect}")
      attrs = temp if temp.length > 0
    end
    @heading = "Container: #{container_name}"
    rr = ResponseRenderer.new(get_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.get_objects_plus(container_name)
    #puts("resp is_a? = #{resp.class.name}")
    if !resp
      @stdlog.debug("#{CN}::  unable to query for objects (authentication?).")
      rr.append_error("Unable to query for objects (authentication?).")
    else
      objects = JSON.load(resp)
      rr.append_class_attrs_start('objects',
        {:container => container_name, :count => objects.length}, get_content_type() == :html)
      objects.each do |object|
        rr.append_instance_start('object', get_content_type() == :html)
        rr.append_attrs_as_row(object, attrs, get_content_type() == :html)
        rr.append_instance_end()
      end
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/containers/<container>
  #

  get %r@#{"/containers/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /containers/<container>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    container_name = cleanse_extension(params[:captures][0])
    #puts("params = #{params.inspect}")
    attrs = ['name', 'bytes']
    if params[:attrs]
      temp = cleanse_extension(params[:attrs]).split('|')
      #puts("temp = #{temp.inspect}")
      attrs = temp if temp.length > 0
    end
    @heading = "Container: #{container_name}"
    rr = ResponseRenderer.new(get_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.get_objects_plus(container_name)
    #puts("resp is_a? = #{resp.class.name}")
    if !resp
      @stdlog.debug("#{CN}::  unable to query for objects (authentication?).")
      rr.append_error("Unable to query for objects (authentication?).")
    else
      objects = JSON.load(resp)
      rr.append_class_attrs_start('objects',
        {:container => container_name, :count => objects.length}, get_content_type() == :html)
      objects.each do |object|
        rr.append_instance_start('object', get_content_type() == :html)
        rr.append_attrs_as_row(object, attrs, get_content_type() == :html)
        rr.append_instance_end()
      end
      rr.append_class_end()
    end  

    @output = rr.data
    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/containers/<container>/objects/<object>/upload
  #

  get %r@#{"/containers/#{ODRIVE_NAME}/objects/#{ODRIVE_NAME}/upload"}#{ODRIVE_EXT}@,
      :authenticated => :user, :session_role => :session_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (GET /containers/<container>/objects/<object>/upload) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    page, page_size = pagination(params)
    @container_name = cleanse_extension(params[:captures][0])
    @object_name = params[:captures][1]

    handle_response(get_content_type(), :upload)
  end

  #
  # GET http://<host>:<port>/<prefix>/containers/<container>/objects/<object>
  #

  get %r@#{ODRIVE_PREFIX + "/containers/#{ODRIVE_NAME}/objects/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_accept_content_type()]

    @stdlog.debug(
      "#{CN}::  (GET /<prefix>/containers/<container>/objects/<object>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    page, page_size = pagination(params)
    container_name = cleanse_extension(params[:captures][0])
    object_name = params[:captures][1]
    @heading = "Container: #{container_name} Object: #{object_name}"
    rr = ResponseRenderer.new(get_accept_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.get_object(container_name, object_name)
    #puts("resp is_a? = #{resp.class.name}")
    if !resp
      if get_accept_content_type() == :octet
        return nil
      else
        @stdlog.debug("#{CN}::  unable to retrieve '#{object_name}'.")
        rr.append_error("Unable to retrieve object named '#{object_name}'.")
      end
    elsif resp.code == 404
      if get_accept_content_type() == :octet
        return nil
      else
        @stdlog.debug("#{CN}::  no object named '#{object_name}'.")
        rr.append_error("No object named '#{object_name}'.")
      end
    else
      download_filespec = './downloads/' + object_name
      File.open(download_filespec, 'wb') do |f|
        f.write(resp.body)
      end
      send_file download_filespec, :filename => object_name,
        :type => 'application/octet-stream'      
      return
    end
    @output = rr.data

    handle_response(get_content_type(), get_content_type() == :html ? :generictable : :generic)
  end

  #
  # GET http://<host>:<port>/containers/<container>/objects/<object>
  #

  get %r@#{"/containers/#{ODRIVE_NAME}/objects/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_accept_content_type()]

    @stdlog.debug("#{CN}::  (GET /containers/<container>/objects/<object>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    page, page_size = pagination(params)
    container_name = cleanse_extension(params[:captures][0])
    object_name = params[:captures][1]
    @heading = "Container: #{container_name} Object: #{object_name}"
    rr = ResponseRenderer.new(get_accept_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.get_object(container_name, object_name)
    if !resp
      if get_accept_content_type() == :octet
        return nil
      else
        @stdlog.debug("#{CN}::  unable to retrieve '#{object_name}'.")
        rr.append_error("Unable to retrieve object named '#{object_name}'.")
      end
    elsif resp.code == 404
      if get_accept_content_type() == :octet
        return nil
      else
        @stdlog.debug("#{CN}::  no object named '#{object_name}'.")
        rr.append_error("No object named '#{object_name}'.")
      end
    else
      download_filespec = './downloads/' + object_name
      File.open(download_filespec, 'wb') do |f|
        f.write(resp.body)
      end
      send_file download_filespec, :filename => object_name,
        :type => 'application/octet-stream'      
      return if !verbose
    end
    @output = rr.data
    @urls = [
      {:url => "/web/containers/#{container_name}",
      :name => "Container #{container_name}"}
    ]

    handle_response(get_content_type(), :genericaction)
  end

  #
  # POST http://<host>:<port>/<prefix>/containers/<container>/objects/<object>/metadata
  #

  post %r@#{ODRIVE_PREFIX + "/containers/#{ODRIVE_NAME}/objects/#{ODRIVE_NAME}/metadata"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_accept_content_type()]

    @stdlog.debug(
      "#{CN}::  (POST /<prefix>/containers/<container>/objects/<object>/metadata) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    page, page_size = pagination(params)
    container_name = cleanse_extension(params[:captures][0])
    #object_name = cleanse_extension(params[:captures][1])
    object_name = params[:captures][1]
    #puts("params = #{params.inspect}")
    @heading = "Container: #{container_name} Object: #{object_name}"
    metadata = {}
    params.each do |k,v|
      metadata[k] = v if k.instance_of?(String) && k.start_with?("X-Object-Meta-")
    end
    rr = ResponseRenderer.new(get_accept_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.post_object_metadata(container_name, object_name, metadata)
    if !resp || resp.code == 404
      @stdlog.debug("#{CN}::  failed to update object metadata: #{object_name}.")
      rr.append_error("Failed to update object metadata: #{object_name}.")
    else
      rr.append_class_attrs_start('POST', {:object => object_name})
      rr.append_instance_attrs_start('metadata', {:object => object_name})
      metadata.each do |k,v|
        rr.append_attr(k, v, 'string')
      end
      rr.append_instance_attrs_start('response', {:object => object_name})
      rr.append_attr("code", resp.code, 'string')
      rr.append_attr("body", resp.body, 'string')
      resp.headers.each do |k,v|
        rr.append_attr("#{k}", v, 'string')
      end
      rr.append_instance_end()
      rr.append_class_end()
    end
    @output = rr.data

    handle_response(get_content_type(), :generic)
  end

  #
  # POST http://<host>:<port>/<prefix>/containers/<container>/objects/<object>
  #

  post %r@#{ODRIVE_PREFIX + "/containers/#{ODRIVE_NAME}/objects/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_accept_content_type()]

    @stdlog.debug(
      "#{CN}::  (POST /<prefix>/containers/<container>/objects/<object>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    page, page_size = pagination(params)
    container_name = cleanse_extension(params[:captures][0])
    #object_name = cleanse_extension(params[:captures][1])
    object_name = params[:captures][1]
    #puts("params = #{params.inspect}")
    @heading = "Container: #{container_name}"
    metadata = {}
    params.each do |k,v|
      if k.instance_of?(String) &&
          (k == "Destination" || k.start_with?("X-Object-Meta-"))
        metadata[k] = v
      end
    end
    rr = ResponseRenderer.new(get_accept_content_type())
    rr.append_class_attrs_start('POST', {:object => object_name})
    if params['Destination']
      @stdlog.debug("#{CN}::  server copy operation to create object: #{object_name}.")
      metadata['Destination'] = "/#{metadata['Destination'].split('/')[2]}/#{object_name}"
      upload_filespec = ''
    elsif params['destination']
      @stdlog.debug("#{CN}::  server copy operation to create object: #{object_name}.")
      @stdlog.debug("#{CN}::  header 'destination' must be 'Destination'.")
        rr.append_error("Header 'destination' must be 'Destination'.")
        rr.append_class_end()
        @output = rr.data
        return haml :uploadstatus
    else
=begin
      # copy framework temp file to local ODrive temp file for verification:
      @stdlog.debug("#{CN}::  upload operation to create object: #{object_name}.")
      upload_filespec = './uploads/' + params[:upfile][:filename]
      File.open(upload_filespec, "w") do |f|
        f.write(params[:upfile][:tempfile].read)
      end
=end
#=begin
      # use framework temp file directly for verification:
      #upload_filespec = params[:upfile][:tempfile]
      tempfile = params[:upfile][:tempfile]
      upload_filespec = tempfile.path
#=end
      if File.size(upload_filespec) > @app_params[:max_file_size]
        rr.append_error("File exceeds limit: #{object_name}.")
        rr.append_class_end()
        @output = rr.data
        return haml :uploadstatus
      end
      upload_digest = Digest::MD5.file(upload_filespec).hexdigest
      rr.append_instance_start('temporary')
      rr.append_attr("status", "Uploaded '#{upload_filespec}'.", 'string')
      rr.append_instance_end()
    end
    rr.append_class_end()
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    #puts( "cloud is: #{cloud}")
    resp = cloud && cloud.put_object(upload_filespec, container_name, object_name, metadata)
    if !resp
      @stdlog.debug("#{CN}::  failed to create (copy) object: #{object_name}.")
      rr.append_error("Failed to create (copy) object: #{object_name}.")
    elsif resp.instance_of?(RestClient::Response) && resp.headers[:etag] == nil
      @stdlog.debug("#{CN}::  no digest for: #{object_name}.")
      rr.append_error("Failed to get digest for: #{object_name}.")
    elsif resp.instance_of?(RestClient::Response) && resp.headers[:etag] != upload_digest
      @stdlog.debug("#{CN}::  MD5 checksum is incorrect for: #{object_name}.")
      rr.append_error("MD5 checksum is incorrect for: #{object_name}.")
    # response from Net::HTTP::Copy operation:
    elsif resp.is_a?(Net::HTTPResponse) && !resp.is_a?(Net::HTTPSuccess)
      rr.append_error("#{resp.body}")
    else
      rr.append_class_attrs_start('PUT', {:object => object_name})
      rr.append_instance_attrs_start('metadata', {:object => object_name})
      metadata.each do |k,v|
        rr.append_attr(k, v, 'string')
      end
      rr.append_instance_end()
      rr.append_instance_attrs_start('response', {:object => object_name})
      rr.append_attr("code", resp.code, 'string')
      rr.append_attr("body", resp.body, 'string')
      if resp.instance_of?(RestClient::Response)
        resp.headers.each do |k,v|
          rr.append_attr("#{k}", v, 'string')
        end
      end
      if resp.is_a?(Net::HTTPSuccess)
        resp.each_header do |k,v|
          rr.append_attr("#{k}", v, 'string')
        end
      end
      rr.append_instance_end()
      rr.append_class_end()
    end
    @output = rr.data

    handle_response(get_content_type(), :generic)
  end

  #
  # GET http://<host>:<port>/upload
  #

  get '/upload',
      :authenticated => :user, :session_role => :session_user do

    haml :upload
  end

  #
  # GET http://<host>:<port>/download/<filename>
  #

  get '/download/:filename',
      :authenticated => :user, :session_role => :session_user do |filename|
    send_file "./files/#{filename}", :filename => filename,
      :type => 'Application/octet-stream'
  end

  #
  # POST http://<host>:<port>/upload-object
  #

  post '/upload-object',
      :authenticated => :user, :session_role => :session_user do
    #content_type ODRIVE_FORMAT[get_content_type()]
    content_type :html

    @stdlog.debug("#{CN}::  (POST /upload-object) request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params = #{params.inspect}")
    #rr = ResponseRenderer.new(get_content_type())
    rr = ResponseRenderer.new(:html)
    @heading = "Upload Object Status"
    upfile = params[:upfile]
    if upfile == nil
      rr.append_error("No file specified.")
      @output = rr.data
      return haml :uploadstatus
    end
    filename = params[:upfile][:filename]
    if filename == nil || filename.length == 0
      rr.append_error("No file specified: '#{filename}'.")
      @output = rr.data
      return haml :uploadstatus
    end
    container_name = params[:container_name]
    if container_name == nil || container_name.length == 0
      rr.append_error("No container specified: '#{container_name}'.")
      @output = rr.data
      return haml :uploadstatus
    end
    object_name = params[:object_name]
    if object_name == nil || object_name.length == 0
      object_name = filename
    end
=begin
    upload_filespec = './uploads/' + filename
    File.open(upload_filespec, "w") do |f|
      f.write(params[:upfile][:tempfile].read)
    end
=end
#=begin
    # use framework temp file directly for verification:
    #upload_filespec = params[:upfile][:tempfile]
    tempfile = params[:upfile][:tempfile]
    upload_filespec = tempfile.path
#=end
    metadata = {}
    if File.size(upload_filespec) > @app_params[:max_file_size]
      rr.append_error("File exceeds limit: #{object_name}.")
      @output = rr.data
      return haml :uploadstatus
    end
    upload_digest = Digest::MD5.file(upload_filespec).hexdigest
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.put_object(upload_filespec, container_name, object_name, metadata)
    if !resp
      @stdlog.debug("#{CN}::  failed to create object: #{object_name}.")
      rr.append_error("Failed to create object: #{object_name}.")
    elsif resp.headers[:etag] == nil
      @stdlog.debug("#{CN}::  no digest for: #{object_name}.")
      rr.append_error("Failed to get digest for: #{object_name}.")
    elsif resp.headers[:etag] != upload_digest
      @stdlog.debug("#{CN}::  MD5 checksum is incorrect for: #{object_name}.")
      rr.append_error("MD5 checksum is incorrect for: #{object_name}.")
    else
      rr.append_class_attrs_start('POST', {:object => object_name}, table=true)
      rr.append_instance_start('temporary', table=true)
      rr.append_attr("status", "Uploaded '#{upload_filespec}'.", 'string', table=true)
      rr.append_instance_end()
      rr.append_instance_attrs_start('metadata', {:object => object_name}, table=true)
      metadata.each do |k,v|
        rr.append_attr(k, v, 'string', table=true)
      end
      rr.append_instance_end()
      rr.append_instance_attrs_start('response', {:object => object_name}, table=true)
      rr.append_attr("code", resp.code, 'string', table=true)
      rr.append_attr("container", container_name, 'string', table=true)
      rr.append_attr("object", object_name, 'string', table=true)
      rr.append_instance_end()
      rr.append_class_end()
    end

    @urls = [
      {:url => "/web/containers/#{container_name}",
      :name => "Container #{container_name}"}
    ]
    @output = rr.data
    handle_response(:html, :genericaction)
  end

  #
  # PUT http://<host>:<port>/<prefix>/containers/<container>
  #

  put %r@#{ODRIVE_PREFIX + "/containers/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (PUT /<prefix>/containers/<container>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    container_name = cleanse_extension(params[:captures][0])
    #puts("params = #{params.inspect}")
    @heading = "Container: #{container_name}"
    rr = ResponseRenderer.new(get_content_type())
    metadata = {}
    params.each do |k,v|
      metadata[k] = v if k.instance_of?(String) && k.start_with?("X-Container-Meta-")
    end
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.put_container(container_name, metadata)
    if !resp
      @stdlog.debug("#{CN}::  failed to create container: #{container_name}.")
      rr.append_error("Failed to create container: #{container_name}.")
    else
      rr.append_class_attrs_start('PUT', {:container => container_name})
      rr.append_instance_start('metadata')
      metadata.each do |k,v|
        rr.append_attr(k, v, 'string')
      end
      rr.append_instance_end()
      rr.append_instance_start('response')
      rr.append_attr("code", resp.code, 'string')
      rr.append_attr("body", resp.body, 'string')
      rr.append_instance_end()
      rr.append_class_end()
    end
    @output = rr.data

    handle_response(get_content_type(), :generic)
  end

  #
  # DELETE http://<host>:<port>/<prefix>/containers/<container>/objects/<object>
  #

  delete %r@#{ODRIVE_PREFIX + "/containers/#{ODRIVE_NAME}/objects/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_accept_content_type()]

    @stdlog.debug(
      "#{CN}::  (DELETE /<prefix>/containers/<container>/objects/<object>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    container_name = cleanse_extension(params[:captures][0])
    #object_name = cleanse_extension(params[:captures][1])
    object_name = params[:captures][1]
    #puts("params = #{params.inspect}")
    @heading = "Container: #{container_name} Object: #{object_name}"
    rr = ResponseRenderer.new(get_accept_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.delete_object(container_name, object_name)
    if !resp || resp.code == 404
      @stdlog.debug("#{CN}::  failed to delete object: #{object_name}.")
      rr.append_error("Failed to delete object: #{object_name}.")
    else
      rr.append_class_attrs_start('DELETE', {:object => object_name})
      rr.append_instance_start('response')
      rr.append_attr("code", resp.code, 'string')
      rr.append_attr("body", resp.body, 'string')
      rr.append_instance_end()
      rr.append_class_end()
    end
    @output = rr.data

    #handle_response(get_content_type(), :generic)
    handle_response(get_accept_content_type(), :generic)
  end

  #
  # DELETE http://<host>:<port>/containers/<container>/objects/<object>
  #

  delete %r@#{"/containers/#{ODRIVE_NAME}/objects/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_accept_content_type()]

    @stdlog.debug(
      "#{CN}::  (DELETE /containers/<container>/objects/<object>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    container_name = cleanse_extension(params[:captures][0])
    #object_name = cleanse_extension(params[:captures][1])
    object_name = params[:captures][1]
    #puts("params = #{params.inspect}")
    @heading = "Container: #{container_name} Object: #{object_name}"
    rr = ResponseRenderer.new(get_accept_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.delete_object(container_name, object_name)
    if !resp || resp.code == 404
      @stdlog.debug("#{CN}::  failed to delete object: #{object_name}.")
      rr.append_error("Failed to delete object: #{object_name}.")
    else
      rr.append_class_attrs_start('DELETE', {:object => object_name}, table=true)
      rr.append_instance_start('response', table=true)
      rr.append_attr("code", resp.code, 'string', table=true)
      rr.append_attr("body", resp.body, 'string', table=true)
      rr.append_instance_end()
      rr.append_class_end()
    end
    @output = rr.data

    #handle_response(get_content_type(), :genericaction)
    handle_response(get_accept_content_type(), :genericaction)
  end

  #
  # DELETE http://<host>:<port>/<prefix>/containers/<container>
  #

  delete %r@#{ODRIVE_PREFIX + "/containers/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (DELETE /<prefix>/containers/<container>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    container_name = cleanse_extension(params[:captures][0])
    #puts("params = #{params.inspect}")
    @heading = "Container: #{container_name}"
    rr = ResponseRenderer.new(get_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.delete_container(container_name)
    if !resp 
      @stdlog.debug(
        "#{CN}::  failed to delete container #{container_name}: unknown response.")
      rr.append_error("Failed to delete container #{container_name}:  unknown response.")
    elsif resp.is_a?(RestClientExceptionResponse) && resp.code == 404
      @stdlog.debug(
        "#{CN}::  failed to delete container #{container_name}: not found.")
      rr.append_error("Failed to delete container #{container_name}: not found.")
    elsif resp.is_a?(RestClientExceptionResponse) && resp.code == 409
      @stdlog.debug(
        "#{CN}::  failed to delete container #{container_name}: not empty.")
      rr.append_error("Failed to delete container #{container_name}: not empty.")
    elsif resp.is_a?(RestClientExceptionResponse) && resp.code == 500
      @stdlog.debug(
        "#{CN}::  failed to delete container #{container_name}: unknown error.")
      rr.append_error("Failed to delete container #{container_name}: unknown error.")
    else
      rr.append_class_attrs_start('DELETE', {:container => container_name})
      rr.append_instance_start('response')
      rr.append_attr("code", resp.code, 'string')
      rr.append_attr("body", resp.body, 'string')
      rr.append_instance_end()
      rr.append_class_end()
    end
    @output = rr.data

    handle_response(get_content_type(), :generic)
  end

  #
  # DELETE http://<host>:<port>/containers/<container>
  #

  delete %r@#{"/containers/#{ODRIVE_NAME}"}#{ODRIVE_EXT}@,
      :authenticated => :user, :authorized_role => :authorized_user do
    content_type ODRIVE_FORMAT[get_content_type()]

    @stdlog.debug("#{CN}::  (DELETE /containers/<container>) \
request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params[:captures] = #{params[:captures].inspect}")
    container_name = cleanse_extension(params[:captures][0])
    #puts("params = #{params.inspect}")
    @heading = "Container: #{container_name}"
    rr = ResponseRenderer.new(get_content_type())
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.delete_container(container_name)
    if !resp 
      @stdlog.debug(
        "#{CN}::  failed to delete container #{container_name}: unknown response.")
      rr.append_error("Failed to delete container #{container_name}:  unknown response.")
    elsif resp.is_a?(RestClientExceptionResponse) && resp.code == 404
      @stdlog.debug(
        "#{CN}::  failed to delete container #{container_name}: not found.")
      rr.append_error("Failed to delete container #{container_name}: not found.")
    elsif resp.is_a?(RestClientExceptionResponse) && resp.code == 409
      @stdlog.debug(
        "#{CN}::  failed to delete container #{container_name}: not empty.")
      rr.append_error("Failed to delete container #{container_name}: not empty.")
    elsif resp.is_a?(RestClientExceptionResponse) && resp.code == 500
      @stdlog.debug(
        "#{CN}::  failed to delete container #{container_name}: unknown error.")
      rr.append_error("Failed to delete container #{container_name}: unknown error.")
    else
      rr.append_class_attrs_start('DELETE', {:container => container_name}, table=true)
      rr.append_instance_start('response', table=true)
      rr.append_attr("code", resp.code, 'string', table=true)
      rr.append_attr("body", resp.body, 'string', table=true)
      rr.append_instance_end()
      rr.append_class_end()
    end
    @output = rr.data

    handle_response(get_content_type(), :generic)
  end

  #
  # POST http://<host>:<port>/containers-action
  #

  post '/containers-action',
      :authenticated => :user, :session_role => :session_user do
    content_type :html

    @stdlog.debug("#{CN}::  (POST /containers-action) request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params = #{params.inspect}")
    rr = ResponseRenderer.new(:html)
    @heading = "Containers Action Status"
    @stdlog.debug("#{CN}::  params = #{params.inspect}.")
    if params[:delete_containers_top] || params[:delete_containers_bottom]
      @stdlog.debug("#{CN}::  handling delete checked containers.")
      containers = []
      params.each do |key,value|
        #puts(key)
        key_str = key.to_s
        if key_str.start_with?("checkbox_")
          #puts(key_str)
          containers << key_str["checkbox_".length..-1]
        end
      end
      if containers.count == 0
        @stdlog.debug("#{CN}::  incorrect deletion action: no containers selected.")
        rr.append_error("Incorrect deletion action: no containers selected.")
      else
        @stdlog.debug("#{CN}::  deleting containers: #{containers.inspect}.")
        cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
        deletions = cloud && cloud.delete_containers(containers)
        @stdlog.debug("#{CN}::  deletions: #{deletions.inspect}.")
        failures = []
        deletions.each do |container_name,resp|
          build_delete_container_response(resp, rr, container_name)
        end
      end
    else
      container_name = nil
      params.each do |key,value|
        #puts(key)
        key_str = key.to_s
        if key_str.start_with?("current_container_")
          #puts(key_str)
          container_name = key_str["current_container_".length..-1]
        end
      end
      #puts("container_name = #{container_name}")
      action_sym = "action_#{container_name}".to_sym
      container_action = params[action_sym]
      #puts("action = #{container_action}")
      if container_action == 'List Objects'
        @stdlog.debug("#{CN}::  handling: #{container_action}.")
        redirect "/web/containers/#{container_name}"
      elsif container_action == 'Upload Object'
        @stdlog.debug("#{CN}::  handling: #{container_action}.")
        @container_name = container_name
        redirect "/webupload/containers/#{container_name}"
      elsif container_action == 'Delete Container'
        @stdlog.debug("#{CN}::  handling: #{container_action}.")
        return delete_container(container_name)
      else
        @stdlog.debug("#{CN}::  incorrect container action: #{container_action}.")
        rr.append_error("Incorrect container action: #{container_action}.")
      end
    end
=begin
    @urls = [
      {:url => "/web/containers/#{container_name}",
      :name => "Container #{container_name}"}
    ]
=end
    @output = rr.data
    handle_response(:html, :genericaction)
  end

  #
  # POST http://<host>:<port>/create-container
  #

  post '/create-container',
      :authenticated => :user, :session_role => :session_user do
    #content_type ODRIVE_FORMAT[get_content_type()]
    content_type :html

    @stdlog.debug("#{CN}::  (POST /create-container) request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params = #{params.inspect}")
    rr = ResponseRenderer.new(:html)
    @heading = "Create Container Status"
    container_name =  params[:container_name]
    if container_name == ""
      @stdlog.debug("#{CN}::  container name is missing (zero length).")
      rr.append_error("Container name is missing (zero length).")
      @urls = nil
    else
      cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
      resp = cloud && cloud.put_container(container_name)
      if !resp
        @stdlog.debug("#{CN}::  failed to create container: #{container_name}.")
        rr.append_error("Failed to create container: #{container_name}.")
      else
        if @verbose
          rr.append_class_attrs_start('CREATE', {:container => container_name}, table=true)
          rr.append_instance_attrs_start('response', {:container => container_name}, table=true)
          rr.append_attr("code", resp.code, 'string', table=true)
          rr.append_attr("body", resp.body, 'string', table=true)
          if resp.instance_of?(RestClient::Response)
            resp.headers.each do |k,v|
              rr.append_attr("#{k}", v, 'string', table=true)
            end
          end
          if resp.is_a?(Net::HTTPSuccess)
            resp.each_header do |k,v|
              rr.append_attr("#{k}", v, 'string', table=true)
            end
          end
          rr.append_instance_end()
          rr.append_class_end()
        else
          rr.append_class_attrs_start('CREATE', {:container => container_name}, table=true)
          rr.append_instance_attrs_start('response', {:container => container_name}, table=true)
          rr.append_attr('status', 'container created successfully', 'string', table=true)
          rr.append_attr('path', "/containers/#{container_name}", 'string', table=true)
          rr.append_instance_end()
          rr.append_class_end()
        end
      end
      @urls = [
        {:url => "/web/containers/#{container_name}",
        :name => "Container #{container_name}"}
      ]
    end
    @output = rr.data

    handle_response(:html, :genericaction)
  end

  def delete_container(container_name)
    @stdlog.debug("#{CN}::  delete_container()...")
    @heading = "Delete Container Status"
    rr = ResponseRenderer.new(:html)
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.delete_container(container_name)
    build_delete_container_response(resp, rr, container_name)
    @output = rr.data

    handle_response(:html, :genericaction)
  end

  def build_delete_container_response(resp, rr, container_name)
    if !resp 
      @stdlog.debug(
        "#{CN}::  failed to delete container #{container_name}: unknown response.")
      rr.append_class_attrs_start('DELETE', {:container => container_name}, table=true)
      rr.append_instance_attrs_start('response', {:container => container_name}, table=true)
      rr.append_attr('status',
        'failed to delete container - unknown response', 'string', table=true)
      rr.append_attr('path', "/containers/#{container_name}", 'string', table=true)
      rr.append_instance_end()
      rr.append_class_end()
    else
      if @verbose
        rr.append_class_attrs_start('DELETE', {:container => container_name}, table=true)
        rr.append_instance_attrs_start('response', {:container => container_name}, table=true)
        rr.append_attr("code", resp.code, 'string', table=true)
        rr.append_attr("body", resp.body, 'string', table=true)
        rr.append_instance_end()
        rr.append_class_end()
      else
        rr.append_class_attrs_start('DELETE', {:container => container_name}, table=true)
        rr.append_instance_attrs_start('response', {:container => container_name}, table=true)
        if resp.is_a?(RestClient::Response)
          rr.append_attr('status', 'container deleted successfully', 'string', table=true)
        elsif resp.is_a?(ODriveUtil::RestClientExceptionResponse)
          if resp.code == 404
            rr.append_attr('status',
              'failed to delete container - not found', 'string', table=true)
          elsif resp.code == 409
            rr.append_attr('status',
              'failed to delete container - not empty', 'string', table=true)
          elsif resp.code == 500
            rr.append_attr('status',
              'failed to delete container - unknown error', 'string', table=true)
          end
        end
        rr.append_attr('path', "/containers/#{container_name}", 'string', table=true)
        rr.append_instance_end()
        rr.append_class_end()
      end
    end
  end

  #
  # POST http://<host>:<port>/objects-action
  #

  post '/objects-action',
      :authenticated => :user, :session_role => :session_user do
    content_type :html

    @stdlog.debug("#{CN}::  (POST /objects-action) request.url = #{request.url}.")
    @stdlog.debug("#{CN}::  params = #{params.inspect}")
    rr = ResponseRenderer.new(:html)
    @heading = "Objects Action Status"
    @stdlog.debug("#{CN}::  params = #{params.inspect}.")
    if params[:delete_objects_top] || params[:delete_objects_bottom]
      @stdlog.debug("#{CN}::  handling delete checked objects.")
      container_name = params[:container_name]
      objects = []
      params.each do |key,value|
        #puts(key)
        key_str = key.to_s
        if key_str.start_with?("checkbox_")
          #puts(key_str)
          objects << key_str["checkbox_".length..-1]
        end
      end
      if objects.count > 0
        return verify_delete_objects(params[:container_name], objects)
      else
        @stdlog.debug("#{CN}::  incorrect deletion action: no objects selected.")
        rr.append_error("Incorrect deletion action: no objects selected.")
      end
    else
      object_name = nil
      params.each do |key,value|
        #puts(key)
        key_str = key.to_s
        if key_str.start_with?("current_object_")
          #puts(key_str)
          object_name = key_str["current_object_".length..-1]
        end
      end
      #puts("object_name = #{object_name}")
      action_sym = "action_#{object_name}".to_sym
      object_action = params[action_sym]
      #puts("action = #{object_action}")
      if object_action == 'Download Object'
        @stdlog.debug("#{CN}::  handling: #{object_action}.")
        return download_object(params[:container_name], object_name)
      elsif object_action == 'Copy Object'
        @stdlog.debug("#{CN}::  handling: #{object_action}.")
        redirect "/webcopy/containers/#{params[:container_name]}/objects/#{object_name}"
      elsif object_action == 'Delete Object'
        @stdlog.debug("#{CN}::  handling: #{object_action}.")
        #return delete_object(params[:container_name], object_name)
        return verify_delete_object(params[:container_name], object_name)
      elsif object_action == 'Object Metadata'
        @stdlog.debug("#{CN}::  handling: #{object_action}.")
        redirect "/containers/#{params[:container_name]}/objects/#{object_name}/metadata"
      else
        @stdlog.debug("#{CN}::  incorrect object action: #{object_action}.")
        rr.append_error("Incorrect object action: #{object_action}.")
      end
    end

    @urls = [
      {:url => "/web/containers/#{container_name}",
      :name => "Container #{container_name}"}
    ]
    @output = rr.data
    handle_response(:html, :genericaction)
  end

  def verify_delete_objects(container_name, objects)
    @stdlog.debug("#{CN}::  verify_delete_object()...")
    #@heading = "Delete Objects Confirmation"
    #rr = ResponseRenderer.new(:html)
    @container_name = container_name
    @objects = objects
    @urls = [
      {:url => "/web/containers/#{container_name}",
      :name => "Container #{container_name}"}
    ]
    #@output = rr.data

    handle_response(:html, :verifydeleteobjects)
  end

  #
  # POST http://<host>:<port>/delete-objects
  #

  post '/delete-objects',
      :authenticated => :user, :session_role => :session_user do
    content_type :html

    @stdlog.debug("#{CN}::  (POST /delete-objects) = #{request.url}.")
    #puts("params = #{params.inspect}")
    action = params[:action]
    container_name = params[:container_name]
    objects = eval(params[:objects]) # convert to an array from string rep.
    #puts("objects: #{objects.inspect}, count: #{objects.count}")
    if action == 'Delete Objects!'
      delete_objects(container_name, objects)
    else
      @heading = "Delete Objects Status"
      rr = ResponseRenderer.new(:html)
      if action == 'Cancel'
        rr.append_class_start('DELETE', table=true)
        rr.append_instance_start('response', table=true)
        rr.append_attr('status', 'object deletions cancelled', 'string', table=true)
        rr.append_attr('count', "#{objects.count}", 'string', table=true)
        s_objects = objects.sort()
        rr.append_attr('path',
          "/containers/#{container_name}/objects/['#{s_objects.first}', ..., '#{s_objects.last}']",
          'string', table=true)
        rr.append_instance_end()
        rr.append_class_end()
      else
        rr.append_error("Unknown error; objects not deleted: #{objects.count}.")
      end
      @urls = [
        {:url => "/web/containers/#{container_name}",
        :name => "Container #{container_name}"}
      ]
      @output = rr.data
      handle_response(:html, :genericaction)
    end
  end

  def delete_objects(container_name, objects)
    @stdlog.debug("#{CN}::  delete_objects()...")
    @stdlog.debug("#{CN}::  deleting objects: #{objects.inspect}.")
    @heading = "Delete Objects Status"
    rr = ResponseRenderer.new(:html)
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    deletions = cloud && cloud.delete_objects(container_name, objects)
    failures = []
    deletions.each do |object_name,resp|
      if !resp || resp.code == 404
        @stdlog.debug("#{CN}::  failed to delete object: #{object_name}.")
        rr.append_error("Failed to delete object: #{object_name}.")
        failures << object_name
      else
        if @verbose
          rr.append_class_attrs_start('DELETE', {:object => object_name}, table=true)
          rr.append_instance_attrs_start('response', {:object => object_name}, table=true)
          rr.append_attr("code", resp.code, 'string', table=true)
          rr.append_attr("body", resp.body, 'string', table=true)
          rr.append_instance_end()
          rr.append_class_end()
        else
          rr.append_class_attrs_start('DELETE', {:object => object_name}, table=true)
          rr.append_instance_attrs_start('response', {:object => object_name}, table=true)
          rr.append_attr('status', 'object deleted successfully', 'string', table=true)
          rr.append_attr('path',
            "/containers/#{container_name}/objects/#{object_name}", 'string', table=true)
          rr.append_instance_end()
          rr.append_class_end()
        end
      end
    end
    @urls = [
      {:url => "/web/containers/#{container_name}",
      :name => "Container #{container_name}"}
    ]
    @output = rr.data

    handle_response(:html, :genericaction)
  end

  def download_object(container_name, object_name)
    @stdlog.debug("#{CN}::  download_object()...")
    @heading = "Container: #{container_name} Object: #{object_name}"
    rr = ResponseRenderer.new(:html)
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.get_object(container_name, object_name)
    if !resp
      if get_accept_content_type() == :octet
        return nil
      else
        @stdlog.debug("#{CN}::  unable to retrieve '#{object_name}'.")
        rr.append_error("Unable to retrieve object named '#{object_name}'.")
      end
    elsif resp.code == 404
      if get_accept_content_type() == :octet
        return nil
      else
        @stdlog.debug("#{CN}::  no object named '#{object_name}'.")
        rr.append_error("No object named '#{object_name}'.")
      end
    else
      @stdlog.debug("#{CN}::  download to './downloads'...")
      download_filespec = './downloads/' + object_name
      File.open(download_filespec, 'wb') do |f|
        f.write(resp.body)
      end
      @stdlog.debug("#{CN}::  download stream...")
      send_file download_filespec, :filename => object_name,
        :type => 'application/octet-stream'
      # send_files halts/returns...
      @stdlog.debug("#{CN}::  object '#{object_name}' downloaded.")
      rr.append_error("Object '#{object_name}' downloaded.")
    end
    @output = rr.data
    @urls = [
      {:url => "/web/containers/#{container_name}",
      :name => "Container #{container_name}"}
    ]

    handle_response(:html, :genericaction)
  end

  def verify_delete_object(container_name, object_name)
    @stdlog.debug("#{CN}::  verify_delete_object()...")
    #@heading = "Delete Object Confirmation"
    #rr = ResponseRenderer.new(:html)
    @container_name = container_name
    @object_name = object_name
    @urls = [
      {:url => "/web/containers/#{container_name}",
      :name => "Container #{container_name}"}
    ]
    #@output = rr.data

    handle_response(:html, :verifydeleteobject)
  end

  #
  # POST http://<host>:<port>/delete-object
  #

  post '/delete-object',
      :authenticated => :user, :session_role => :session_user do
    content_type :html

    @stdlog.debug("#{CN}::  (POST /delete-object) = #{request.url}.")
    #puts("params = #{params.inspect}")
    action = params[:action]
    container_name = params[:container_name]
    object_name = params[:object_name]
    if action == 'Delete Object'
      delete_object(container_name, object_name)
    else
      @heading = "Delete Object Status"
      rr = ResponseRenderer.new(:html)
      if action == 'Cancel'
        rr.append_class_attrs_start('DELETE', {:object => object_name}, table=true)
        rr.append_instance_attrs_start('response', {:object => object_name}, table=true)
        rr.append_attr('status', 'object deletion cancelled', 'string', table=true)
        rr.append_attr('path',
          "/containers/#{container_name}/objects/#{object_name}",
          'string', table=true)
        rr.append_instance_end()
        rr.append_class_end()
      else
        rr.append_error("Unknown error; object not deleted: #{object_name}.")
      end
      @urls = [
        {:url => "/web/containers/#{container_name}",
        :name => "Container #{container_name}"}
      ]
     @output = rr.data
      handle_response(:html, :genericaction)
    end
  end

  def delete_object(container_name, object_name)
    @stdlog.debug("#{CN}::  delete_object()...")
    @heading = "Delete Object Status"
    rr = ResponseRenderer.new(:html)
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.delete_object(container_name, object_name)
    if !resp || resp.code == 404
      @stdlog.debug("#{CN}::  failed to delete object: #{object_name}.")
      rr.append_error("Failed to delete object: #{object_name}.")
      @output = rr.data
      handle_response(:html, :generic)
    else
      if @verbose
        rr.append_class_attrs_start('DELETE', {:object => object_name}, table=true)
        rr.append_instance_attrs_start('response', {:object => object_name}, table=true)
        rr.append_attr("code", resp.code, 'string', table=true)
        rr.append_attr("body", resp.body, 'string', table=true)
        rr.append_instance_end()
        rr.append_class_end()
      else
        rr.append_class_attrs_start('DELETE', {:object => object_name}, table=true)
        rr.append_instance_attrs_start('response', {:object => object_name}, table=true)
        rr.append_attr('status', 'object deleted successfully', 'string', table=true)
        rr.append_attr('path',
          "/containers/#{container_name}/objects/#{object_name}", 'string', table=true)
        rr.append_instance_end()
        rr.append_class_end()
      end
    end
    @urls = [
      {:url => "/web/containers/#{container_name}",
      :name => "Container #{container_name}"}
    ]
    @output = rr.data

    handle_response(:html, :genericaction)
  end

  #
  # POST http://<host>:<port>/copy-object
  #

  post '/copy-object',
      :authenticated => :user, :session_role => :session_user do
    content_type :html

    @stdlog.debug("#{CN}::  (POST /copy-object) = #{request.url}.")
    #puts("params = #{params.inspect}")

    @stdlog.debug("#{CN}::  copy_object()...")
    @heading = "Copy Object Status"
    rr = ResponseRenderer.new(:html)
    from_container_name =  params[:from_container_name]
    from_object_name = params[:from_object_name]
    to_container_name =  params[:to_container_name]
    to_object_name = params[:to_object_name]
    metadata = {'Destination' => "/#{to_container_name}/#{to_object_name}"}
    cloud = route_connection_set_up(session[:user_id] && session[:user_id].to_sym)
    resp = cloud && cloud.put_object('', from_container_name, from_object_name, metadata)
    if !resp
      @stdlog.debug("#{CN}::  failed to copy object: #{from_object_name}.")
      rr.append_error("Failed to copy object: #{from_object_name}.")
    # response from Net::HTTP::Copy operation:
    elsif resp.is_a?(Net::HTTPResponse) && resp.is_a?(Net::HTTPNotFound)
      rr.append_class_attrs_start('COPY', {:object => to_object_name}, table=true)
      rr.append_instance_attrs_start('response', {:object => to_object_name}, table=true)
      rr.append_attr('status', 'source or target container does not exist', 'string', table=true)
      rr.append_instance_end()
      rr.append_class_end()
    elsif resp.is_a?(Net::HTTPResponse) && !resp.is_a?(Net::HTTPSuccess)
      rr.append_error("#{resp.body}")
    else
      if @verbose
        rr.append_class_attrs_start('COPY', {:object => to_object_name}, table=true)
        rr.append_instance_attrs_start('response', {:object => to_object_name}, table=true)
        rr.append_attr("code", resp.code, 'string', table=true)
        if resp.instance_of?(RestClient::Response)
          resp.headers.each do |k,v|
            rr.append_attr("#{k}", v, 'string', table=true)
          end
        end
        if resp.is_a?(Net::HTTPSuccess)
          resp.each_header do |k,v|
            rr.append_attr("#{k}", v, 'string', table=true)
          end
        end
        rr.append_instance_end()
        rr.append_class_end()
      else
        rr.append_class_attrs_start('COPY', {:object => to_object_name}, table=true)
        rr.append_instance_attrs_start('response', {:object => to_object_name}, table=true)
        rr.append_attr('status', 'object copied successfully', 'string', table=true)
        rr.append_attr('from',
          "/containers/#{from_container_name}/#{from_object_name}", 'string', table=true)
        rr.append_attr('to',
          "/containers/#{to_container_name}/#{to_object_name}", 'string', table=true)
        rr.append_instance_end()
        rr.append_class_end()
      end
    end
    @urls = [
      {:url => "/web/containers/#{from_container_name}",
      :name => "Container #{from_container_name}"},
      {:url => "/web/containers/#{to_container_name}",
      :name => "Container #{to_container_name}"}
    ]
    @output = rr.data

    handle_response(:html, :genericaction)
  end

  #
  # GET http://<host>:<port>/objects-action-status
  #

  get '/objects-action-status',
      :authenticated => :user, :session_role => :session_user do
    content_type :html

    haml :genericaction
  end

  #
  # POST http://<host>:<port>/generic-redirect
  #

  post 'generic-redirect' do  # auth ???
   redirect_url = params[:redirect_url]
    if !redirect_url
      @output = "Unknown redirect-url processing error #1."
    else
      redirect redirect_url
    end
  end

  #
  # POST http://<host>:<port>/ok-status
  #

  post 'ok-status' do  # auth ???
    userid = session[:user_id]
    user = UserManager.manage_password(userid, params)
    userid = session[:user_id]
    status_url = params[:status_url]
    if !status_url
      @output = "Unknown status url processing error #1."
    else
      redirect status_url
    end
  end
end
