module ActionController
  module Resources
    class Resource
      attr_reader :path_prefix, :name_prefix, :path_segment 

      def initialize(entities, options)
        @plural   ||= entities
        @singular ||= options[:singular] || plural.to_s.singularize
        @path_segment = options.delete(:as) || @plural 

        @options = options

        arrange_actions
        add_default_actions
        set_prefixes
      end

      def path
        @path ||= "#{path_prefix}/#{path_segment}"
      end

    end
  end
end