#
# URL:  http://localhost:9292/
# Cmd:  rackup1.8 helloworld.ru
#


class HelloWorld
  def call(env)
    [200, {'Content-Type' => 'text/html'}, ["Hello, world!"]]
  end
end

run HelloWorld.new
