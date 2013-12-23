#!/usr/bin/env ruby

#
# = Summary
#
# Exercises the Configurator class.
#

require 'odrive_config.rb'

begin
  status = 0
  odrive = ODriveConfig::Configurator.new
  puts "Configuration settings:"
  puts("Here's loglevel via 'odrive.loglevel': #{odrive.loglevel}")
  puts("Here's loglevel via 'odrive.get_value(:loglevel)': " \
    "#{odrive.get_value(:loglevel)}")
  puts("Here's loglevel via 'odrive.get_value(:loglevel, 'info')': " \
    "#{odrive.get_value(:loglevel, 'info')}")
  puts("Here's loglevel with mispelling via 'odrive.get_value(:logglevel, 'info')': " \
    "#{odrive.get_value(:logglevel, 'info')}")
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)
