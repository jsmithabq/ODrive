#!/usr/bin/env ruby

#
# = Summary
#
# sass2css generates a CSS document from a SASS document.
#

require 'sass'

if ARGV.length == 1 && ["-h", "-help", "--help"].include?(ARGV[0])
  puts
  puts("usage: ruby sass2css.rb <sass-document>")
  exit(0)
end
src_spec = ARGV.length == 1 ? ARGV[0] : 'stylesheet.sass'
tgt_spec = (src_spec.end_with?('.sass') ? src_spec[0..-6] : src_spec) + '.css'

begin
  status = 0
  template = File.read(src_spec)
  sass_engine = Sass::Engine.new(template)
  output = sass_engine.render
  #puts output
  out = File.open(tgt_spec, "wb")
  out.write(output)
rescue => e
  puts('Rendering error for:  ' + src_spec)
  puts(e)
  status = -1
end
exit(status)
