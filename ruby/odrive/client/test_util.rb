#
# == Summary
#
# TestUtil provides utility methods for testing.  These methods are designed
# as mixins for the test scripts.
#

require 'restclient'

#
# TestUtil provides utility methods for testing.  These methods are designed
# as mixins for the test scripts.
#

module TestUtil
  #
  # Returns the host and port, processing optional command-line arguments.
  #
  # Script invocation:
  #   ruby <test-script> [<host>] [<port>]
  #
  # Method invocation:
  #   host, port = get_host_port()
  #
  # Defaults:
  #   host == localhost
  #   port == 6789
  #
  
  def get_host_port
    host, port = "localhost", "6789"
    host = ARGV[0] if ARGV.length == 1
    host, port =  ARGV[0], ARGV[1] if ARGV.length == 2
    return host, port
  end
  
  def get_host_port_resource
    host, port, resource = "localhost", "6789", "/"
    host = ARGV[0] if ARGV.length == 1
    host, port = ARGV[0], ARGV[1] if ARGV.length == 2
    host, port, resource = ARGV[0], ARGV[1], ARGV[2] if ARGV.length == 3
    return host, port, resource
  end
  
  def get_host_port_resource_filename
    host, port, resource, filename = "localhost", "6789", "/", "no-filename"
    host = ARGV[0] if ARGV.length == 1
    host, port = ARGV[0], ARGV[1] if ARGV.length == 2
    host, port, resource = ARGV[0], ARGV[1], ARGV[2] if ARGV.length == 3
    host, port, resource, filename = ARGV[0], ARGV[1], ARGV[2], ARGV[3] if ARGV.length == 4
    return host, port, resource, filename
  end
  
  def get_host_port_resource_source
    host, port, resource, source = "localhost", "6789", "/", "no-source"
    host = ARGV[0] if ARGV.length == 1
    host, port = ARGV[0], ARGV[1] if ARGV.length == 2
    host, port, resource = ARGV[0], ARGV[1], ARGV[2] if ARGV.length == 3
    host, port, resource, source = ARGV[0], ARGV[1], ARGV[2], ARGV[3] if ARGV.length == 4
    return host, port, resource, source
  end
  
  def get_host_port_resource_destination
    host, port, resource, destination = "localhost", "6789", "/", "no-destination"
    host = ARGV[0] if ARGV.length == 1
    host, port = ARGV[0], ARGV[1] if ARGV.length == 2
    host, port, resource = ARGV[0], ARGV[1], ARGV[2] if ARGV.length == 3
    host, port, resource, destination = ARGV[0], ARGV[1], ARGV[2], ARGV[3] if ARGV.length == 4
    return host, port, resource, destination
  end
  
  def get_endpoint_token
    endpoint, token = "", ""
    endpoint, token = ARGV[0], ARGV[1] if ARGV.length == 2
    return endpoint, token
  end
  
  #
  # Prompts for console input and returns the string.
  #
  # Arguments:
  #   prompt - the user prompt - String
  #

  def prompt_read_string(prompt="generic prompt: ")
    puts(prompt)
    stdin = IO.new(0) # avoid the infamous Errno::ENOENT error from gets()
    response = stdin.gets().chomp
  end

  #
  # Prints to standard output the response received by a RESTful client.
  #
  # Arguments:
  #   response - the response returned from a RESTful method call - RestClient::Response
  #
  # Example output:
  #   code: 200
  #   content-type: text/html
  #   body:
  #   <html>
  #     <whatever>
  #   </html>
  #

  def print_response(response)
    if response.is_a?(RestClient::Response)
      puts("code: #{response.code}")
      puts("content-type: #{response.headers[:content_type]}")
      puts("body:\n#{response.body}")
    elsif response.is_a?(Exception)
      puts("#{response.class}: #{response.message}")
    else
      puts("Unknown response object: #{response}")
    end
  end
  def print_response_headers(response)
    if response.is_a?(RestClient::Response)
      response.headers.each do |k,v|
        puts("#{k} : #{v}")
      end
    elsif response.is_a?(Exception)
      puts("#{response.class}: #{response.message}")
    else
      puts("Unknown response object: #{response}")
    end
  end
end
