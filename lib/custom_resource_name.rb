module ActionController
  module Resources
    class Resource
      attr_reader :path_segment, :edit_as

      def initialize(entities, options)
        @plural   ||= entities
        @singular ||= options[:singular] || plural.to_s.singularize
        @path_segment = options.delete(:as) || @plural 
        
        @new_as ||= options.delete(:new_as) || 'new'
        @edit_as ||= options.delete(:edit_as) || 'edit'

        @options = options

        arrange_actions
        add_default_actions
        set_prefixes
      end

      def path
        @path ||= "#{path_prefix}/#{path_segment}"
      end

      def new_path
        @new_path ||= "#{path}/#{@new_as}"
      end
      
    end
  
    def map_member_actions(map, resource)
      resource.member_methods.each do |method, actions|
        actions.each do |action|
          action_options = action_options_for(action, resource, method)
          
          if action == :edit
            map.named_route("#{action}_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}#{resource.action_separator}#{resource.edit_as}", action_options)
            map.named_route("formatted_#{action}_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}#{resource.action_separator}#{resource.edit_as}.:format",action_options)
          elsif
            map.named_route("#{action}_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}#{resource.action_separator}#{action}", action_options)
            map.named_route("formatted_#{action}_#{resource.name_prefix}#{resource.singular}", "#{resource.member_path}#{resource.action_separator}#{action}.:format",action_options)
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