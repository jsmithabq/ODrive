#
# == Summary
#
# RestUtil provides utility methods.  These methods are designed
# as mixins for scripts.
#

require 'restclient'

#
# RestUtil provides utility methods.  These methods are designed
# as mixins for scripts.
#

module RestUtil
  #
  # Returns the endpoint and token.
  #
  # Script invocation:
  #   ruby <test-script> [<endpoint>] [<token>]
  #
  # Method invocation:
  #   endpoint, token = get_endpoint_token()
  #
  # Defaults:
  #   host == ''
  #   port == ''
  #
  
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
