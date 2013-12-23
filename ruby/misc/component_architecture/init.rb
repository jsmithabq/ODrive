
#
# Locates all route-related source files.
#

require 'routes/filters.rb'
require 'routes/head.rb'
require 'routes/session.rb'
require 'routes/user.rb'
require 'routes/drive.rb'
require 'routes/components.rb'
logger = ODRIVE_CONFIG.create_logger_from_config(false)
path = Pathname.new(ODRIVE_COMPONENT_DIR)
if path.directory?
  count = 0
  path.entries.each do |entry|
    comp_path = path + entry
    if comp_path.parent.realpath == path.realpath
      count += 1
      comp_path.entries.each do |comp_path_entry|
        comp_path_comp = comp_path + comp_path_entry
        if comp_path_comp.to_s.end_with?('.rb')
          require comp_path_comp
        end
      end
    end
  end
  logger.debug("ODriveApp::  number of components = #{count}.")
end
require 'routes/tail.rb'
