#!/usr/bin/env ruby

#
# Visit:  http://localhost:4567/hello/Frank
#

require 'sinatra'

get '/hello/:name' do
  @name = params[:name]
  erb :hello
end

__END__
@@ layout
<html>
<body>
  <%= yield %>
</body>
</html>

@@ hello
<h3>Hello <%= @name %>!</h3>
