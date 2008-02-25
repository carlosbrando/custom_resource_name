module ActionController
  module Resources
    class Resource
      attr_reader :path_segment, :actions_as, :resources_as

      def initialize(entities, options)
        @plural   ||= entities
        @singular ||= options[:singular] || plural.to_s.singularize

        @resources_as = options.delete(:resources_as) || {}
        @actions_as = options.delete(:actions_as) || {}

        @path_segment = options.delete(:as) || @resources_as[entities] || @plural

        @options = options

        arrange_actions
        add_default_actions
        set_prefixes
      end

      def path
        @path ||= "#{path_prefix}/#{path_segment}"
      end

      def new_path
        action_new = @actions_as[:new] || 'new'
        @new_path ||= "#{path}/#{action_new}"
      end
    end

    def map_resource(entities, options = {}, &block)
      options.merge!(:actions_as => @actions_as, :resources_as => @resources_as)
      resource = Resource.new(entities, options)

      with_options :controller => resource.controller do |map|
        map_collection_actions(map, resource)
        map_default_collection_actions(map, resource)
        map_new_actions(map, resource)
        map_member_actions(map, resource)

        map_associations(resource, options)

        if block_given?
          with_options(:path_prefix => resource.nesting_path_prefix, :name_prefix => resource.nesting_name_prefix, :namespace => options[:namespace], &block)
        end
      end
    end

    def aliases(*args)
      if args.size > 0
        options = args.extract_options!
        if args[0] == :resources
          @resources_as = options || {}
        elsif args[0] == :actions
          @actions_as = options || {}
        end
      end
    end

    def map_collection_actions(map, resource)
      resource.collection_methods.each do |method, actions|
        actions.each do |action|
          action_options = action_options_for(action, resource, method)

          if resource.actions_as.has_key?(action)
            map.named_route("#{action}_#{resource.name_prefix}#{resource.plural}", "#{resource.path}#{resource.action_separator}#{resource.actions_as[action]}", action_options)
            map.named_route("formatted_#{action}_#{resource.name_prefix}#{resource.plural}", "#{resource.path}#{resource.action_separator}#{resource.actions_as[action]}.:format", action_options)
          else
            map.named_route("#{action}_#{resource.name_prefix}#{resource.plural}", "#{resource.path}#{resource.action_separator}#{action}", action_options)
            map.named_route("formatted_#{action}_#{resource.name_prefix}#{resource.plural}", "#{resource.path}#{resource.action_separator}#{action}.:format", action_options)
          end
        end
      end
    end

    def map_member_actions(map, resource)
      resource.member_methods.each do |method, actions|
        actions.each do |action|
          action_options = action_options_for(action, resource, method)

          if resource.actions_as.has_key?(action)
            map.named_route("#{action}_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}#{resource.action_separator}#{resource.actions_as[action]}", action_options)
            map.named_route("formatted_#{action}_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}#{resource.action_separator}#{resource.actions_as[action]}.:format", action_options)
          elsif
            map.named_route("#{action}_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}#{resource.action_separator}#{action}", action_options)
            map.named_route("formatted_#{action}_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}#{resource.action_separator}#{action}.:format", action_options)
          end
        end
      end

      show_action_options = action_options_for("show", resource)
      map.named_route("#{resource.name_prefix}#{resource.singular}", resource.member_path, show_action_options)
      map.named_route("formatted_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}.:format", show_action_options)

      update_action_options = action_options_for("update", resource)
      map.connect(resource.member_path, update_action_options)
      map.connect("#{resource.member_path}.:format", update_action_options)

      destroy_action_options = action_options_for("destroy", resource)
      map.connect(resource.member_path, destroy_action_options)
      map.connect("#{resource.member_path}.:format", destroy_action_options)
    end
    
  end
end