module ActionController
  module Resources
    def map_associations(resource, options)
      path_prefix = "#{options.delete(:path_prefix)}#{resource.nesting_path_prefix}"
      name_prefix = "#{options.delete(:name_prefix)}#{resource.nesting_name_prefix}"

      Array(options[:has_many]).each do |association|
        resources(association, :path_prefix => path_prefix, :name_prefix => name_prefix, :namespace => options[:namespace])
      end

      Array(options[:has_one]).each do |association|
        resource(association, :path_prefix => path_prefix, :name_prefix => name_prefix, :namespace => options[:namespace])
      end
    end
  end
end