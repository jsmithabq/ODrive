#!/usr/bin/env ruby

#
# == Notice
#
# This file should be executed (indirectly) from <tt>odrive.sh</tt>,
# in order to pick up the path includes.
#
# == Summary
#
# ODriveApp implements core ODrive resource/route handling.  This
# application can be extended by including <tt>odrive.rb</tt> and
# augmenting the core functionality with additional route handling.
#

require 'odrive.rb'
require 'user_manager.rb' # must be after 'odrive.rb'
require 'resource_manager.rb' # must be after 'odrive.rb'

ODriveApp.run!
