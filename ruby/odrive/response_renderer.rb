
#
# == Summary
#
# ResponseRenderer generates simple output as an array of <whatever>, where each
# array element represents another "vertical component" that's handed back for
# the response output, and <whatever> is formatted as HTML, XML, YAML, JSON, Atom,
# etc.
# 
# This code is a placeholder solution for a more sophisticated generation of
# content with the appropriate generators, e.g, <tt>XTemplate</tt>, etc.
# Currently, YAML generation is simple with tagging, and without using built-in
# functionality such as <tt><some-object>.to_yaml()</tt>, etc.
#

require 'uri/common'
require 'json'
require 'yaml'

#
# Provides a stack for managing tags.
#

class TagStack
  #
  # Instantiates a tag stack.
  #
  
  def initialize()
    @tags = []
  end
  
  #
  # Returns whether or not the stack is empty.
  #
  
  def empty?
    @tags.length == 0
  end
  
   #
  # Removes and returns the top tag from the stack.
  #
  
  def pop
    @tags.delete_at(@tags.length - 1)
  end
  
  #
  # Adds a new tag to the top of the stack.
  #
  # Arguments:
  #   tag - the tag to push as the top element of the tag stack - String
  #
  
  def push(tag)
    @tags << tag
  end
  
  #
  # Returns the top tag from the stack.
  #
  
  def top
    @tags.last
  end
end


#
# Provides basic rendering of output for the response instance.
#

class ResponseRenderer
  attr_reader :data, :format
  
  #
  # Instantiates a response rendering object.
  #
  # Arguments:
  #   format - the optional output format, e.g., :xml - Symbol
  #
  
  def initialize(format=:html)
    @data = []
    @line_num = 0
    @format = format
    @wrapper_tags = TagStack.new
    @class_tags = TagStack.new
    @instance_tags = TagStack.new
  end
  
  #
  # Returns a string representation of the instance state.
  #
  
  def to_s()
    "[data = #{@data}, format = #{@format}]"
  end
  
  #
  # Appends a (transparent) wrapper start tag, primarily for bundling multiple
  # classes for XML output.
  #
  # Arguments:
  #   tag - the wrapper tag - String
  #   table - whether or not rendering context is HTML table - Boolean
  #
  
  def append_wrapper_start(tag, table=false)
    @wrapper_tags.push(tag)
    if @format == :xml
      @data << "<#{@wrapper_tags.top} type=\"array\">\n"
    elsif @format == :yaml
      @data << "---\n#{@wrapper_tags.top}:\n"
    elsif @format == :json
      @data << "#{ODRIVE_JSON_PAD}\"#{@wrapper_tags.top}\": [\n"
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      @data << "\n" if !table
    end
  end
  
  #
  # Appends content, if any, to the output.
  # Arguments:
  #   content - the arbitrary content - String
  #
  
  def append_wrapper_content(serial=false, *content)
    content.each_with_index do |list,i|
      if @format == :yaml
        @data << ODRIVE_YAML_PAD + '-'
      end
      list.each do |element|
        if @format == :xml
          @data << ODRIVE_XML_PAD
        elsif @format == :yaml
          #@data << ODRIVE_YAML_PAD
          @data << ' '
        elsif @format == :json
          @data << ODRIVE_JSON_PAD
        elsif @format == :atom
          # ??? defer until ODriveUtil.handle_response()
        else # ".txt" || ".text"
          # nothing, just copying content
        end
        @data << element
      end
      if serial && i < (content.count - 1) && @data.last.end_with?("\n")
        @data[@data.length - 1][-1...-1] = ','
      end
    end
  end
  
  #
  # Appends an end tag, if any, to the output.
  #
  
  def append_wrapper_end()
    if @format == :xml
      @data << "</#{@wrapper_tags.top}>\n"
    elsif @format == :yaml
      @data << "...\n"
    elsif @format == :json
      @data << "#{ODRIVE_JSON_PAD}]\n"
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      @data << "\n"
    end
    @wrapper_tags.pop
  end
  
  #
  # Appends a start tag, if any, to the output.
  #
  # Arguments:
  #   tag - the class tag - String
  #   table - whether or not rendering context is HTML table - Boolean
  #
  
  def append_class_start(tag, table=false)
    @class_tags.push(tag)
    if @format == :xml
      @data << "<#{@class_tags.top} type=\"array\">\n"
    elsif @format == :yaml
      @data << "#{@class_tags.top}:\n"
    elsif @format == :json
      @data << "#{ODRIVE_JSON_PAD}\"#{@class_tags.top}\": [\n"
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      @data << "\n" if !table
    end
  end
  
  #
  # Appends a start tag, if any, to the output.
  #
  # Arguments:
  #   tag - the class tag - String
  #   attrs - a list of key-value XML attributes - Hash
  #   table - whether or not rendering context is HTML table - Boolean
  #
  
  def append_class_attrs_start(tag, attrs, table=false)
    @class_tags.push(tag)
    if @format == :xml
      @data << "<#{@class_tags.top} "
      if attrs && attrs.is_a?(Hash)
        attrs.each do |k,v|
          @data << "#{k}=\"#{v}\" "
        end
      end
      @data << "type=\"array\">\n"
    elsif @format == :yaml
      @data << "#{@class_tags.top}:\n"
    elsif @format == :json
      @data << "#{ODRIVE_JSON_PAD}\"#{@class_tags.top}\": [\n"
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      @data << "\n" if !table
    end
  end
  
  #
  # Appends an end tag, if any, to the output.
  #
  
  def append_class_end()
    if @format == :xml
      @data << "</#{@class_tags.top}>\n"
    elsif @format == :yaml
      #@data << "\n"
    elsif @format == :json
      @data[@data.length - 1][-2..-2] = '' if @data.last.end_with?(",\n")
      @data << "#{ODRIVE_JSON_PAD}]\n"
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      @data << "\n"
    end
    @class_tags.pop
  end
  
  #
  # Appends a start tag, if any, to the output.
  #
  # Arguments:
  #   tag - the instance tag - String
  #   table - whether or not rendering context is HTML table - Boolean
  #
  
  def append_instance_start(tag, table=false)
    @instance_tags.push(tag)
    if @format == :xml
      @data << ODRIVE_XML_PAD << "<#{@instance_tags.top}>\n"
    elsif @format == :yaml
      @data << ODRIVE_YAML_PAD << '- ' << "{\n"
    elsif @format == :json
      @data << "#{ODRIVE_JSON_PAD * 2}{\n"
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      @data << "\n" if !table
    end
  end
  
  #
  # Appends a start tag, if any, to the output.
  #
  # Arguments:
  #   tag - the instance tag - String
  #   attrs - a list of key-value XML attributes - Hash
  #   table - whether or not rendering context is HTML table - Boolean
  #
  
  def append_instance_attrs_start(tag, attrs, table=false)
    @instance_tags.push(tag)
    if @format == :xml
      @data << ODRIVE_XML_PAD << "<#{@instance_tags.top} "
      if attrs && attrs.is_a?(Hash)
        attrs.each do |k,v|
          @data << "#{k}=\"#{v}\" "
        end
      end
      @data << ">\n"
    elsif @format == :yaml
      @data << ODRIVE_YAML_PAD << '- ' << "{\n"
    elsif @format == :json
      @data << "#{ODRIVE_JSON_PAD * 2}{\n"
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      @data << "\n" if !table
    end
  end
  
  #
  # Appends a end tag, if any, to the output.
  #
  
  def append_instance_end()
    if @format == :xml
      @data << ODRIVE_XML_PAD << "</#{@instance_tags.top}>\n"
    elsif @format == :yaml
      @data[@data.length - 1][-2..-2] = '' if @data.last.end_with?(",\n")
      @data << ODRIVE_YAML_PAD << "}\n"
    elsif @format == :json
      @data[@data.length - 1][-2..-2] = '' if @data.last.end_with?(",\n")
      @data << "#{ODRIVE_JSON_PAD * 2}},\n"
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      @data << "\n"
    end
    @instance_tags.pop
  end
  
  #
  # Appends an attribute tag to the output.
  #
  # Arguments:
  #   tag - the attribute tag - String
  #   value - the tag value - String
  #   type - the attribute type - String
  #   table - whether or not rendering context is HTML table - Boolean
  #   explicit_html - whether or not the request was explicit for HTML- Boolean
  #
  
  def append_attr(tag, value, type, table=false, explicit_html=false)
    value ||= ""
    value = "********" if tag.include?("password")
    if @format == :xml
      @data << ODRIVE_XML_PAD*2 << "<#{tag} type=\"#{type}\">#{value}</#{tag}>\n"
    elsif @format == :yaml
      @data << ODRIVE_YAML_PAD*2 << "#{tag}: #{value},\n"
    elsif @format == :json
      @data << ODRIVE_JSON_PAD*3 << "#{tag}: #{value},\n"
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      #value = value.chomp if tag == "password"
      if explicit_html && URI.extract(value).size == 1 # NOT a foolproof URL check
        value = "<a href='#{value}'>#{value}</a>"
      end
#      @data << "#{tag}: #{value}\n"
      if table
        #@data << "#{tag}: " if tag && tag.length > 0
        if tag && tag.length > 0
          @data << "<tr><td>#{tag}:</td>"
        else
          @data << "<tr>"
        end
        @data << "<td>#{value}</td></tr>"
      else
        @data << "#{tag}: " if tag && tag.length > 0
        @data << "#{value}\n"
      end
    end
  end
  
  #
  # Appends attributes to the output as HTML table rows.
  #
  # Arguments:
  #   attrs - the attributes - Hash
  #   subset - the list of keys - Array
  #
  
  def append_attrs_as_table_row(attrs, subset)
    return nil if @format != :html
    @data << "<tr>"
    if subset && subset.is_a?(Array)
      subset.each do |i|
        if !attrs[i]
          # pass through ???
        elsif i == 'bytes'
          @data << "<td>#{bytes_to_size_rep(attrs[i])}</td>"
        else
          @data << "<td>#{attrs[i]}</td>"
        end
        @data << "<td>&nbsp;</td>"
      end
    end
    @data << "</tr>\n"
  end
  
  #
  # Appends attributes to the output as format-dependent rows.
  #
  # Arguments:
  #   attrs - the attributes - Hash
  #   subset - the list of keys - Array
  #
  
  def append_attrs_as_row(attrs, subset, table=false)
    if subset && subset.is_a?(Array)
      subset.each do |i|
        if !attrs[i]
          # pass through ???
        else
          value = (i == 'bytes' && table) ? "#{bytes_to_size_rep(attrs[i])}" : "#{attrs[i]}"
          append_attr(i, value, 'string', table)
        end
      end
    end
  end
  
  #
  # Appends a set of attribute tag-value-type triples to the output.
  #
  # Arguments:
  #   attrs - the set of tag-value-type triples, e.g., [[t1,v1, dt1], [t2,v2, dt2]] - Array
  #   table - whether or not rendering context is HTML table - Boolean
  #   explicit_html - whether or not the request was explicit for HTML- Boolean
  # Example:
  #
  #   [[nil, true, :checkbox], [name, value, :string], [size, value, :string],
  #     [actions, value, :select]]
  #
  
  def append_attrs_table(attrs, table=false, explicit_html=false)
=begin
    value ||= ""
    value = "********" if tag.include?("password")
    if @format == :xml
      @data << ODRIVE_XML_PAD*2 << "<#{tag} type=\"#{type}\">#{value}</#{tag}>\n"
    elsif @format == :yaml
      @data << ODRIVE_YAML_PAD*3 << "#{value},\n"
    elsif @format == :json
      # ??? defer until ODriveUtil.handle_response()
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      #value = value.chomp if tag == "password"
      if explicit_html && URI.extract(value).size == 1 # NOT a foolproof URL check
        value = "<a href='#{value}'>#{value}</a>"
      end
#      @data << "#{tag}: #{value}\n"
      if table
        #@data << "#{tag}: " if tag && tag.length > 0
        if tag && tag.length > 0
          @data << "<tr><td>#{tag}:</td>"
        else
          @data << "<tr>"
        end
          @data << "<td>#{value}</td></tr>\n"
      else
        @data << "#{tag}: " if tag && tag.length > 0
        @data << "#{value}\n"
      end
    end
=end
  end
  
  def append_container()
    
  end
  
  def append_object()
    
  end
  
  #
  # Appends its value as an individual line wrapped as a paragraph to the output.
  #
  # Argument:
  #   value - the value - String
  #
  
  def append_header(type, value)
    if type == 'th'
      @data << "<tr><th>#{value}</th></tr>\n"
    else
      @data << "<#{type}>#{value}</#{type}>\n"
    end
  end
  
  #
  # Appends its value as an individual line wrapped as a paragraph to the output.
  #
  # Argument:
  #   value - the value - String
  #
  
  def append_para(value)
    @data << "<p>#{value}</p>\n"
  end
  
  #
  # Appends its value as an individual line wrapped as a list item to the output.
  #
  # Argument:
  #   value - the value - String
  #
  
  def append_list(value)
    @data << "<li>#{value}</li>\n"
  end
  
  #
  # Appends multiple attributes to the output.
  #
  # WARNING:  This method assumes that the argument is a Ruby WSDL-related
  # object for which zero-arity methods can be interpreted as <tt>attr_reader</tt>
  # attributes.
  #
  # Arguments:
  #   obj - the object
  #
  
  def append_attrs_wsdl(obj)
    attributes = obj.public_methods(false)
    attributes.each do |attr|
      meth = obj.method(attr)
      if meth.arity == 0 # attr_reader?
        tag = meth.name
        value = meth.call
        type = case 
          when value.instance_of?(String)
            "string"
          when value.instance_of?(Fixnum)
            "integer"
          when value.instance_of?(Float)
            "float"
          when value.instance_of?(NilClass), value.instance_of?(TrueClass)
            "boolean"
          else
            "unknown"
          end
        value ||= ""
        value = "********" if tag.include?("password")
        if @format == :xml
          @data << ODRIVE_XML_PAD*2 << "<#{tag} type=\"#{type}\">#{value}</#{tag}>\n"
        elsif @format == :yaml
          @data << ODRIVE_YAML_PAD*3 << "#{value},\n"
          #@data << ODRIVE_YAML_PAD*2 << "#{tag}: #{value},\n"
        elsif @format == :json
          #@data << ODRIVE_YAML_PAD*3 << "#{tag}: #{value},\n" ???
        elsif @format == :atom
          # ??? defer until ODriveUtil.handle_response()
        else # ".txt" || ".text"
          #value = value.chomp if tag == "password"
          @data << "#{tag}: #{value}\n"
        end
      end
    end
  end
  
  #
  # Appends multiple attributes to the output by calling append_attr, for each
  # table column in the Sequel::Dataset row.
  #
  # Arguments:
  #   table_columns - the columns of interest from the dataset - Array of Array
  #     [[:<column_name>, "<column_type>"]...]
  #   ds_row - the dataset row from which to build attribute info - Sequel::DataSet
  #   request_url - the request URL - String
  #   emit_url - whether to emit a resource URL in lieu of the actual content - Boolean
  #   table - whether or not rendering context is HTML table - Boolean
  #   key - the optional "logical key," used to specify the table column that
  #     provides the id for the resource URL - Symbol
  #
  
  def append_attr_content_or_url(table_columns, ds_row, request_url, emit_url, table=false, *key)
    if emit_url
      if key.length == 0
        append_attr('href', request_url, 'string', table)
      else
        request_url << '/' unless request_url.end_with?('/')
        id = (key.length == 1) ? key[0] : table_columns[0][0]
        append_attr('href', "#{request_url}#{ds_row[id]}", 'string', table)
      end
    else
      table_columns.each do |column|
        append_attr("#{column[0]}", "#{ds_row[column[0]]}", column[1], table)
      end
    end
  end
  
  #
  # Appends multiple attributes to the output by calling append_attr, for each
  # table column in the Sequel::Dataset row.
  #
  # Arguments:
  #   columns - the columns from the dataset providing type info - Array of Array
  #     [[:<column_name>, :<column_type>]...]
  #   data - the raw data values corresponding to the column info - Array
  #   request_url - the request URL - String
  #   emit_url - whether to emit a resource URL in lieu of the actual content - Boolean
  #   table - whether or not rendering context is HTML table - Boolean
  #   scalar - if emitting a URL, whether the URL is complete or requires
  #     appending the first data value to complete the resource specification- Boolean
  #
  
  def append_data_content_or_url(columns, data, request_url, emit_url, table=false, scalar=true)
    if emit_url
      if scalar
        append_attr('href', request_url, 'string', table)
      else
        request_url << '/' unless request_url.end_with?('/')
        append_attr('href', "#{request_url}#{data[0]}", 'string', table)
      end
    else
      data.each_with_index do |value, i|
        append_attr("#{columns[i][0]}", "#{value}", "#{columns[i][1]}", table) 
      end
    end
  end
  
  #
  # Appends a custom URL.
  #
  # Arguments:
  #   tag - the attribute tag - String
  #   request_url - the request URL - String
  #   value - the tag value - String
  #   table - whether or not rendering context is HTML table - Boolean
  #   explicit_html - whether or not the request was explicit for HTML- Boolean
  #
  
  def append_attr_url(tag, request_url, value, table=false, explicit_html=false)
    request_url << '/' unless request_url.end_with?('/')
    append_attr(tag, "#{request_url}#{value}", 'string', explicit_html, table)
  end
  
  #
  # Appends an error message to the output.
  #
  # Arguments:
  #   text - the text for the error message - String, or Array of String
  #
  
  def append_error(text)
    if text.instance_of?(Array)
      messages = text
    else
      messages = Array.new() << text
    end
    if @format == :xml
      append_class_start('errors')
      messages.each do |error|
        append_instance_start('error')
        append_attr('message', error, 'string')
        append_instance_end()
      end
      append_class_end()
    elsif @format == :yaml
      append_class_start('errors')
      messages.each do |error|
        append_instance_start('')
        append_attr('', error, '')
        append_instance_end()
      end
      append_class_end()      
    elsif @format == :json
      append_class_start('errors')
      messages.each do |error|
        append_instance_start('')
        append_attr('', error, '')
        append_instance_end()
      end
      append_class_end()      
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      messages.each do |error|
        @data << "#{error}\n"
      end
    end
  end
  
  #
  # Appends a comment to the output.
  #
  # Arguments:
  #   comment - the text for the comment - String
  #
  
  def append_comment(comment)
    if @format == :xml
      @data << "<!-- #{comment} -->\n"
    elsif @format == :yaml
      @data << "# #{comment}\n"
    elsif @format == :json
      # emit nothing for not
    elsif @format == :atom
      # ??? defer until ODriveUtil.handle_response()
    else # ".txt" || ".text"
      @data << "#{comment}\n"
    end
  end
  
  #
  # Appends arbitrary content to the output.
  #
  # Arguments:
  #   content - the text
  #
  
  def append(content)
    @data << content
  end
  
  #
  # Appends an empty line to the output, which only makes sense for text output.
  #
  
  def append_empty_line()
    @data << "\n"
  end
  
  #
  # Appends its arguments as a single line of space-separated values to the output.
  #
  # Arguments:
  #   content - the values as method arguments - String
  #
  
  def append_line(*content)
    temp = ""
    content.each_with_index do |content, i|
      temp << content
      temp << " " if i < content.size
    end
    @data << "#{temp}\n"
  end
  
  #
  # Appends its arguments as a single line of space-separated values to the output.
  #
  # Prepends consecutive line numbers each time this method is called for the
  # response-renderer instance.
  #
  # Arguments:
  #   content - the values as method arguments - String
  #
  
  def append_line_with_num(*content)
    @line_num += 1
    temp = ""
    content.each_with_index do |content, i|
      temp << content
      temp << " " if i < content.size
    end
    @data << "#{@line_num}: #{temp}\n"
  end
end
