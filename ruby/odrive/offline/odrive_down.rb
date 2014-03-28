#!/usr/bin/env ruby

#
#

%w'sinatra/base haml sass '.each {|lib| require lib}

%w'../response_renderer'.each {|c| require c}

ODRIVE_HOME = '/'
ODRIVE_PREFIX = 'rest'
ODRIVE_UNKNOWN = '/*'
#ODRIVE_PORT = 6799
ODRIVE_PORT = 10000
ODRIVE_EXT = '(|\.html|\.xml|\.yaml|\.json|\.atom|\.text|\.txt)$'
ODRIVE_JSON_PAD = '  '
ODRIVE_XML_PAD = '  '
ODRIVE_YAML_PAD = '  '
ODRIVE_DEFAULT_HEADER_FOOTER = ""
ODRIVE_FORMAT = {
  :text => 'text/plain',
  :html => 'text/html',
  :yaml => 'text/yaml',
  :atom => 'application/atom+xml',
  :json => 'application/json',
  :xml => 'application/xml',
  :octet => 'application/octet-stream',
  :bin => 'application/octet-stream',
}

class ODriveAppDown < Sinatra::Base

  set :sessions, true
  set :port, ODRIVE_PORT

  get '/stylesheet.css' do
    headers 'Content-Type' => 'text/css; charset=utf-8'

    sass :styledefault
  end

  [%r@#{ODRIVE_PREFIX}#{ODRIVE_EXT}@,
    %r@#{ODRIVE_HOME}#{ODRIVE_EXT}@
  ].each do |path|
    get path do
      @heading = "ODrive is down for maintenance!"
      rr = ResponseRenderer.new(get_content_type())
      rr.append_class_start("ODriveMessager")
      rr.append_error("No further information available.")
      rr.append_class_end()

      @output = rr.data
      @banner = ODRIVE_DEFAULT_HEADER_FOOTER
      handle_response(get_content_type(),
        get_content_type() == :html ? :indextable : :indexcd)
    end
  end

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

  def match_condition(list, condition)
    list.each do |item|
      result = condition.call(item)
      return result if result
    end
  end

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

  def handle_response(format, view)
    if request.get? || request.put? || request.post?
      last_modified([DateTime.now])
    end
    puts("setting response header Content-Location to: " +
      "'#{cleanse_extension(request.fullpath)}'."
    )
    headers({"Content-Location" => cleanse_extension(request.fullpath)})
    if format == :html
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

  def cleanse_extension(spec)
    if spec.end_with?('.xml')
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
    else
       get_accept_content_type()
    end
  end

  def get_accept_content_type()
    #puts("request is: #{request.inspect}")
    if request.accept.size == 1
      #puts("#{MN}::  request accept: '#{request.accept[0]}'.")
      if (type_symbol = type_to_symbol(request.accept[0])) != nil
        #puts "accept[0] -> " + type_symbol.to_s
        type_symbol
      else
        :html
      end
    elsif request.accept.size > 1
      acceptable = request.accept()
      puts("request accept: '#{acceptable}'.")
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
end

#ODriveAppDown.run!
