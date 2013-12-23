#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/test-chars/whatever
# Visit:  http://localhost:4567/test-chars/what ever
# Visit:  
# Visit:  http://localhost:4567/test-word-chars/one
# Visit:  http://localhost:4567/test-word-chars/one two
# Visit:  http://localhost:4567/test-word-chars/one,two
# Visit:  
# Visit:  http://localhost:4567/test-two-words/one
# Visit:  http://localhost:4567/test-two-words/ one two
# Visit:  
#

require 'sinatra/base'

#
# Test various regular expressions that are valid in Ruby's irb
# against Sinatra's route processing, because Sinnatra interjects
# its own compiler process.
#
# The only objective is go test retrieval of two capture parameters,
# not the regular expressions.
#

class TestApp < Sinatra::Base

#set :port, 10101

  def handle_params
    #"params[:captures] contains: #{params[:captures]}"
    output = nil
    begin
      output = []
      params[:captures].each_with_index do |cap, index|
        output << "index = #{index}, capture param = \'#{cap}\'<br>"
      end
    rescue ex
      output = "no capture params..."
    end
    return output
  end
  
  get %r@/test-chars/(.+)@ do
    handle_params()
  end

  #get %r@/test-word-chars/\w+@ do  # works in irb, but not Sinatra
  get %r@/test-word-chars/(\w+)@ do  # works Sinatra
    handle_params()
  end

  #get %r@/test-two-words/([ ]*\w+[ ]*){2}@ do # one capture param
  get %r@/test-two-words/([ ]*\w+[ ]*)([ ]*\w+[ ]*)?@ do # two capture params
    handle_params()
  end

  get '/*' do
    'Unhandled route'
  end
end

TestApp.run!
