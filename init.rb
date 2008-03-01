require 'custom_resource_name'

if Rails::VERSION::MAJOR < 2
  require 'extract_options'
  require 'map_associations'
end

require 'resources' if RAILS_GEM_VERSION < '1.2.6'