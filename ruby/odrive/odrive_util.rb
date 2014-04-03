
#
# == Summary
#
# ODriveUtil is a module that provide mixin methods for ODriveApp.
#
# In a runtime sense, this module depends on being included in ODriveApp, so
# that it has access to <tt>request</tt>, <tt>response</tt>, etc.
#

module ODriveUtil
  MN = ODriveUtil.name

  #
  # Invokes HAML processing relative to the component hierarchy.
  #
  # Arguments:
  #  template_spec - the file spec for the template files, relative to
  #    the top-level component hierarchy, e.g.,
  #    <tt>":hello/views/hello"</tt> - Symbol
  #  options - the HAML options - Hash
  #  locals - the HAML locals - Hash
  #

  def component_haml(template_spec, options={}, locals={})
    haml "../components/#{template_spec.to_s}".to_sym, options, locals
  end

  #
  # Checks for recognized implied format types by ".<ext>".
  #
  # Arguments:
  #   f - the requested output format, e.g., '.txt', '.xml' - String
  #

  def is_recognized_format?(f)
    f == '.html' || f == '.xml' || f == '.yaml' || f == '.json' || f == '.text' || f == '.txt' 
  end

  #
  # Checks for recognized media types (for formatting) and returns a symbol.
  #
  # Arguments:
  #   type - the requested media format, e.g., 'application/xml', 'text/yaml' - String
  #

  def type_to_symbol(type)
    return nil if type == nil 
    if type == 'application/json'
      :json
    elsif type == 'application/xml'
      :xml
    elsif type == 'application/atom+xml'
      :atom
    elsif type == 'text/html'
      :html
    elsif type == 'text/yaml'
      :yaml
    elsif type == 'text/plain'
      :text
    elsif type == 'application/octet-stream'
      :octet
    else
      nil
    end
  end

  #
  # Checks for recognized ".<ext>" types and returns a symbol.
  #
  # Arguments:
  #   ext - the ".<ext>", e.g., '.xml', '.yaml' - String
  #

  def ext_to_symbol(ext)
    return nil if ext == nil 
    if ext == '.xml'
      :xml
    elsif type == '.yaml'
      :yaml
    elsif type == '.json'
      :json
    elsif type == '.text'
      :text
    elsif type == '.txt'
      :text
    elsif type == '.html'
      :html
    elsif type == '.bin'
      :octet
    else
      nil
    end
  end

  #
  # Checks a list for an element that matches the condition, as specified by a
  # lambda and returns the first element that meets the condition, otherwise nil.
  #
  # Arguments:
  #   list - the "each-capable" data structure - typically, an array
  #   condition - a lambda function that returns a Boolean result
  #

  def match_condition(list, condition)
    list.each do |item|
      result = condition.call(item)
      return result if result
    end
  end

  #
  # Checks a source hash for elements that match the keys subset and produces a
  # target hash by reducing the target to the matched (k,v) pairs.
  #
  # Arguments:
  #   source - the source hash - Hash
  #   list - the keys - Array
  #

  def reduce_to(source, list)
    target = {}
    list.each do |key|
      target[key] = source[key] if source[key]
    end
    target
  end

  #
  # Invokes a specific view handler, or passes the formulated output.
  #
  # Arguments:
  #   format - the output format, e.g., :html, :xml - Symbol
  #   view - the HAML view - Symbol
  #

  def handle_response(format, view)
    if request.get? || request.put? || request.post?
      last_modified([DateTime.now])
    end
    @stdlog.debug(
      "#{MN}::  setting response header Content-Location to: " +
      "'#{cleanse_extension(request.fullpath)}'."
    )
    headers({"Content-Location" => cleanse_extension(request.fullpath)})
    if format == :html  # for now, do not fall through to else clause ???
      haml view
    elsif format == :xml
      @output
    elsif format == :yaml
      @output
    elsif format == :json
      # wrap it:
      "{\n#{@output}}\n"
    elsif format == :text
      @output
    else
      haml view
    end
  end

  #
  # Tests whether or not the content is serial.
  #

  def serial_content?()
    get_content_type() == :json
  end

  #
  # Tests whether or not the content is XML or HTML.
  #

  def content_is_markup?()
    get_content_type() == :html || get_content_type() == :xml
  end

  #
  # Gets the content type as a symbol for the current request's path.
  # Supports the de facto standard of appending ".<ext>" to elicit a
  # response in the specified format, e.g.,
  #   * http://localhost:5678/users
  #   * http://localhost:5678/users.xml
  #   * http://localhost:5678/users/jdoe
  #   * http://localhost:5678/users/jdoe.xml
  #
  # If there is no ".<ext>", then honors {'Accept' => <type>} requests
  # for "application/json", "applicatin/xml", "text/html', "text/yaml",
  # "text/plain", and "application/atom+xml".
  #

  def get_content_type()
    #puts("request is: #{request.inspect}")
    path = request.fullpath
    form_hash = request.env['rack.request.form_hash']
    #puts("form_hash = #{form_hash}")
    if path.end_with?('.xml')
      :xml
    elsif path.end_with?('.yaml')
      :yaml
    elsif path.end_with?('.json')
      :json
    elsif path.end_with?('.text')
      :text
    elsif path.end_with?('.txt')
      :text
=begin
    elsif (type_symbol = get_accept_content_type()) != nil
      type_symbol
    else
      :html
=end
    else
       get_accept_content_type()
    end
  end

  #
  # Gets the content type as a symbol for the current request's path as
  # requested through an 'Accept' header parameter.
  # Honors "application/json", "applicatin/xml", "text/html', "text/yaml",
  # "text/plain", and "application/atom+xml".
  #

  def get_accept_content_type()
    #puts("request is: #{request.inspect}")
    if request.accept.size == 1
      @stdlog.debug("#{MN}::  request accept: '#{request.accept[0]}'.")
      if (type_symbol = type_to_symbol(request.accept[0])) != nil
        #puts "accept[0] -> " + type_symbol.to_s
        type_symbol
      else
        :html
      end
    elsif request.accept.size > 1
      acceptable = request.accept()
      @stdlog.debug("#{MN}::  request accept: '#{acceptable}'.")
      if (type_symbol = match_condition(acceptable, lambda {|x| type_to_symbol(x)})) != nil
        #puts "accept[x] -> " + type_symbol.to_s
        type_symbol
      else
        :html
      end
    elsif defined?(form_hash) && (type_symbol = type_to_symbol(form_hash['Accept'])) != nil
      #puts "form_hash -> " + type_symbol.to_s
      type_symbol
    else
      :octet
    end
  end

  #
  # Compares strings for case insensitive match up to n characters.
  #
  # Arguments:
  #   s1 - the first string - String
  #   s2 - the second string - String
  #

  def strncmp(s1, s2, len=0)
    if len == 0
      s1.casecmp(s2) == 0
    else
      s1[0..len].casecmp(s2[0..len]) == 0
    end
  end

  #
  # Tests whether or not the request URL included an explicit <tt>.html</tt>
  # spec, e.g.,
  #   * http://localhost:5678/about
  #   * http://localhost:5678/about.html
  #
  # Arguments:
  #   request - the URL request - String
  #

  def is_explicit_html_request?(request)
    request.fullpath.end_with?('.html')
  end

  #
  # Gets the spec with the trailing format spec removed (if present).
  #
  # Arguments:
  #   spec - the route specification - String
  #

  def cleanse_extension(spec)
    if spec.end_with?('.xml')  # for now, use explicit case structure
      spec.chomp!('.xml')
    elsif spec.end_with?('.yaml')
      spec.chomp!('.yaml')
    elsif spec.end_with?('.json')
      spec.chomp!('.json')
    elsif spec.end_with?('.html')
      spec.chomp!('.html')
    elsif spec.end_with?('.text')
      spec.chomp!('.text')
    elsif spec.end_with?('.txt')
      spec.chomp!('.txt')
    else
      spec
    end
  end

  #
  # Returns the URL trimmed down to the specified component.
  #
  # Arguments:
  #   url - the URL  - String
  #   component - the URL component - String
  #

  def get_relative_url(url, component)
    url = cleanse_extension(url)
    url[0, url.index(component) + component.length]
  end

  #
  # Determines pagination parameters.
  #
  # Returns an array of <tt>[page, size]</tt>
  #
  # Arguments:
  #   params - the request instance's parameters - Hash
  #

  def pagination(params)
    if page = params[:page]
      page = cleanse_extension(page).to_i
      @stdlog.debug("#{MN}::  page = #{page}")
      if page_size = params[:size]
        page_size = cleanse_extension(page_size).to_i
      else
        page_size = @page_size
      end
    end
    [page, page_size]
  end

  #
  # Performs any necessary set up for route handling, e.g., setting up a
  # resource connection (currently, a stateless "connection").
  #
  # Arguments:
  #   profile_sym - the profile name, or <tt>nil</tt> for Basic Auth - Symbol
  #   refresh - force refresh - Boolean
  #

  def route_connection_set_up(profile_sym, refresh=false)
    if profile_sym && profile_sym.instance_of?(Symbol)
      profile = ResourceManager.get_parameter(profile_sym) # is nil possible ???
      if profile_sym == :default_profile || !profile || !profile.cloud || refresh
        swift = SwiftProvider.new(profile.name,
          profile.host, profile.admin_port, profile.compute_port,
          profile.tenant, profile.user, profile.password
        )
        profile.cloud = (swift && swift.valid?) ? swift : nil
        @stdlog.debug("#{MN}::  connection configured...")
        swift
      else
        ResourceManager.get_parameter(session[:user_id].to_sym).cloud
      end
    elsif UserManager.is_user_auth_basic?(request)
      #puts("request.env = " + request.env.inspect)
      auth = UserManager.get_user_auth_basic(request)
      form_hash = request.env["rack.request.form_hash"]
      #puts("form_hash = " + form_hash.inspect)
      cloud_password = resolve_args(form_hash && form_hash["cloud_password"],
        request.env['HTTP_CLOUD_PASSWORD'],
        get_config_value(:cloud_password, OPENSTACK_DEFAULT_PASSWORD))
      swift = SwiftProvider.new("BasicAuth",
        resolve_args(form_hash && form_hash["cloud_host"],
          request.env['HTTP_CLOUD_HOST'],
          get_config_value(:cloud_host, ODRIVE_HOSTS[0])),
        resolve_args(form_hash && form_hash["cloud_admin_port"],
          request.env['HTTP_CLOUD_ADMIN_PORT'],
          get_config_value(:cloud_admin_port, OPENSTACK_ADMIN_PORT)),
        resolve_args(form_hash && form_hash["cloud_compute_port"],
          request.env['HTTP_CLOUD_COMPUTE_PORT'],
          get_config_value(:cloud_compute_port, OPENSTACK_COMPUTE_PORT)),
        resolve_args(form_hash && form_hash["cloud_tenant"],
          request.env['HTTP_CLOUD_TENANT'],
          get_config_value(:cloud_tenant, OPENSTACK_DEFAULT_TENANT)),
        resolve_args(form_hash && form_hash["cloud_user"],
          request.env['HTTP_CLOUD_USER'],
          get_config_value(:cloud_user, OPENSTACK_DEFAULT_USER)),
        ODRIVE_AES.encrypt(cloud_password))
    else
      @stdlog.debug("#{MN}::  failed to configure connection:")
      @stdlog.debug("#{MN}::  #{ex.class}: #{ex.message}")
      false
    end
  end

  #
  # Returns the first argument that's not <tt>nil</tt>, or <tt>nil</tt>.
  #
  # Arguments:
  #   *args - the varying number of arguments - Object
  #

  def resolve_args(*args)
    return nil if !args
    args.each do |a|
      return a if a
    end
    nil
  end
  
  #
  # Performs any necessary clean up for route handling, e.g., closing a
  # database.
  #

  def route_connection_clean_up()
    #@swift = nil
    @stdlog.debug("#{MN}::  connection deconfigured...")
  end

  #
  # Retrieves a subset of a hashtable.
  #
  # Arguments:
  #   table - the hashtable - Hash
  #   list - the list of keys - Array
  #
  
  def hash_subset(table, list)
    raise(ArgumentError, "Expected Hash") if !table.is_a?(Hash)
    raise(ArgumentError, "Expected Array") if !value.is_a?(Array)
    subset = {}  # make this the same type as the first arg ???
    list.each do |i|
      subset[i] = table[i] if table[i]
    end
    subset
  end

  #
  # Converts a value in bytes to bytes, kilobytes, megabytes, or gigabytes.
  #
  # Arguments:
  #   value - the byte count - Integer
  #
  
  def bytes_to_size_rep(value)
    raise(ArgumentError, "Expected Integer") if !value.is_a?(Integer)
    case
      when value > ODRIVE_GIGA then "%6.1f G" % (value / ODRIVE_GIGA_F)
      when value > ODRIVE_MEGA then "%6.1f M" % (value / ODRIVE_MEGA_F)
      when value > ODRIVE_KILO then "%6.1f K" % (value / ODRIVE_KILO_F)
      else "#{value} bytes"
    end
  end
  
  #
  # Returns an array of arrays of column info, one sub-array for each table
  # column.  The sub-arrays contain column name as a symbol and column type
  # as a string.
  #
  # Arguments:
  #   table_symbol - the table name - Symbol
  #

  def get_columns_table(table_symbol)
    columns = []
    table_schema = @db.schema(table_symbol)
    table_schema.each do |column|
      columns << [column[0], column[1][:type]]
    end
    return columns
  end

  #
  # Returns an array of arrays of column info, one sub-array for each table
  # column.  The sub-arrays contain column name as a symbol and column type
  # as a string.  Multiple tables are processed in order, as specified by the
  # list of tables.
  #
  # Arguments:
  #   dataset - the dataset associated with the table - Sequel::Dataset - currently unused
  #   table_symbols - the list of table names - Array of Symbol
  #

  def get_columns_join(dataset, table_symbols)
    columns = []
    table_symbols.each do |table_symbol|
      table_schema = @db.schema(table_symbol)
      table_schema.each do |column|
        columns << [column[0], column[1][:type]]
      end
    end
    return columns
  end

  #
  # Returns an array of arrays of column info, one sub-array for each table
  # column.  The sub-arrays contain column name as a symbol and column type
  # as a string, e.g.,
  #   [[:vaultid, :integer], [:detid, :integer], [:x, :float], [:y, :float]]
  # Multiple tables are processed in order, as specified by the list of tables,
  # but filtered by the specified subset of columns.
  #
  # If the tables have duplicate columns, there will be a sub-array for each
  # column (i.e., per table).
  #
  # Note:  Sequel::Models::subset() could be used to set up filtered datasets.
  #
  # Arguments:
  #   dataset - the dataset associated with the table - Sequel::Dataset - currently unused
  #   col_symbols - the filter list of column names - Array of Symbol
  #   table_symbols - the list of table names - Array of Symbol
  #

  def get_columns_subset(dataset, col_symbols, table_symbols)
    columns = []
    table_symbols.each do |table_symbol|
      table_schema = @db.schema(table_symbol)
      table_schema.each do |column|
        columns << [column[0], column[1][:type]] if col_symbols.include?(column[0])
      end
    end
    return columns
  end

  #
  # Returns an array of arrays of column info, one sub-array for each table
  # column.  The sub-arrays contain column name as a symbol and column type
  # as a string, e.g.,
  #   [[:vaultid, :integer], [:detid, :integer], [:x, :float], [:y, :float]]
  # Multiple tables are processed in order, as specified by the list of tables,
  # but filtered by the specified subset of columns.
  #
  # If the tables have duplicate columns, the first table's column sub-array will
  # be included and matching columns for subsequent tables will be omitted.
  #
  # Note:  Sequel::Models::subset() could be used to set up filtered datasets.
  #
  # Arguments:
  #   dataset - the dataset associated with the table - Sequel::Dataset - currently unused
  #   col_symbols - the filter list of column names - Array of Symbol
  #   table_symbols - the list of table names - Array of Symbol
  #

  def get_columns_subset_unique(dataset, col_symbols, table_symbols)
    columns = []
    table_symbols.each do |table_symbol|
      table_schema = @db.schema(table_symbol)
      table_schema.each do |column|
        columns << [column[0], column[1][:type]] if
          col_symbols.include?(column[0]) && !include_column?(columns, column[0])
      end
    end
    return columns
  end

  #
  # Checks an array of subarrays for the presence of a subarray describing
  # the specified column.  The array of arrays must have the format:
  #   [[:vaultid, :integer], [:detid, :integer], [:x, :float], [:y, :float]]
  #
  # Arguments:
  #   list - the array of subarrays
  #   column - candidate column - Symbol
  #

  def include_column?(list, column)
    list.each do |subarray|
      return true if subarray[0] == column
    end
    return false
  end

  #
  # List all or a subset of users.
  #
  # Arguments:
  #   user_request - the request type, e.g., LIST_MULTIPLE_USERS - Constant (Symbol)
  #   request - the request, Hash
  #   params - the parameters
  #   table - whether or not rendering context is HTML table - Boolean
  #   user_subset - the filter list of users - Array of String - optional
  #

  def list_users(user_request, request, params, table=false, *user_subset)
    content_type ODRIVE_FORMAT[get_content_type()]
    
    as_table_rows = table && get_content_type() == :html
    #
    # For this app, arbitrarily configure the attribute list.  Administrative
    # users see all attributes; other users see a limited subset.
    #
    if UserManager.is_user_auth_basic?(request)
      auth = UserManager.get_user_auth_basic(request)
      userid = auth.credentials.first
    else
      userid = session[:user_id]
    end
    attr_list = (userid && userid == 'admin') ? [:all] : [:userid, :name]

    if user_subset.length == 1 && user_subset[0].instance_of?(Array)
      result =
        UserManager.list_users(params, userid, attr_list, user_subset[0])
      emit_url = user_subset[0].length == 1 ? @emit_url_for_one_item : @emit_url
    else
      result = UserManager.list_users(params, userid, attr_list)
      emit_url = @emit_url
    end
    if !result
      @output = "Unknown list-users error #1."
    elsif result == UserManager::USER_DB_ERROR
      @stdlog.debug("#{MN}::  for user '#{userid}', list-users failed.")
      @output = "For user <strong>#{userid}</strong>, list-users failed!"
    elsif result == UserManager::TYPE_ERROR
      @stdlog.debug(
        "#{MN}::  for user '#{userid}', list-users failed--type error .")
      @output =
        "For user <strong>#{userid}</strong>, list-users failed--type error!"
    elsif result.instance_of?(Array)
      rr = ResponseRenderer.new(get_content_type())
      user_list, columns = result # list of user data and column data, both arrays
      rr.append_class_start('users', as_table_rows)
      user_list.each do |user|
        rr.append_instance_start('user', as_table_rows)
        rr.append_data_content_or_url(columns, user,
          cleanse_extension(request.url), emit_url, as_table_rows, user_request == LIST_ONE_USER)
        rr.append_instance_end()
        rr.append("<tr><td>&nbsp;</td></tr>") if as_table_rows
      end
      rr.append_class_end()
      @output = rr.data
    else
      @output = "Unknown list-users error #2."
    end
    
    handle_response(get_content_type(), as_table_rows ? :generictable : :users)
  end

  #
  # Provides an alternative to RestClient exceptions instead of Response objects.
  #

  class RestClientExceptionResponse
    attr_accessor :body, :code

    #
    # Instantiates a response object.
    #

    def initialize()
      @body = ""
      @code = ""
    end
  end
end
