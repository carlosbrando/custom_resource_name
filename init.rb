require 'custom_resource_name'

if Rails::VERSION::MAJOR < 2
  require 'extract_options.rb'
  require 'map_associations.rb'
end