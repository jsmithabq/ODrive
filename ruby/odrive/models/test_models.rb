#!/usr/bin/env ruby

#
# = Summary
#
# This test should be run with 'odrive' as the working directory, because
# 'user_models.rb' currently has a relative reference to the database:
#
# .../odrive$ ruby models/test_models.rb
#

require 'models/user_models.rb'

include UserModels

begin
  status = 0
  user = User['testuser']
  puts
  puts user.inspect
  role = Role['test']
  puts
  puts role.inspect
  ru = RoleUser['test', 'testuser']
  puts
  puts ru.inspect
rescue => ex
  puts('Exception:')
  puts(ex)
  status = -1
end
exit(status)
