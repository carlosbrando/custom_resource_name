module ActionController
  module Resources
    class Resource #:nodoc:
      def action_separator
        @action_separator ||= Base.resource_action_separator
      end
      
      def nesting_name_prefix
        "#{name_prefix}#{singular}_"
      end
    end
  end
  
  class Base
    # Controls the resource action separator
    @@resource_action_separator = "/"
    cattr_accessor :resource_action_separator
  end
end