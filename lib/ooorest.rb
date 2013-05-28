require 'active_support'
require 'ooorest/engine'
require 'ooorest/action_window_controller'
require 'action_pack'
require 'kaminari'
require 'kaminari/models/page_scope_methods'

module Ooorest

  DEFAULT_AUTHENTICATION = Proc.new do
    request.env['warden'].try(:authenticate!)
  end

  DEFAULT_ATTR_ACCESSIBLE_ROLE = Proc.new { :default }

  DEFAULT_AUTHORIZE = Proc.new {}

  DEFAULT_OE_USER_METHOD = Proc.new do
    uid = 1
  end

  module OoorestConfig
    extend ActiveSupport::Concern
    module ClassMethods

      def authenticate_with(&blk)
        @authenticate = blk if blk
        @authenticate || DEFAULT_AUTHENTICATION
      end

      def authorize_with(*args, &block)
        extension = args.shift
        if(extension) #TODO
#          @authorize = Proc.new {
#            @authorization_adapter = RailsAdmin::AUTHORIZATION_ADAPTERS[extension].new(*([self] + args).compact)
#          }
        else
          @authorize = block if block
        end
        @authorize || DEFAULT_AUTHORIZE
      end 

      def current_oe_user_method(*args, &block)
        @current_user_method = block if block
        @current_user_method || DEFAULT_OE_USER_METHOD
      end

    end
  end

  include OoorestConfig


  module CurrentOEUser
    def current_oe_user
      instance_eval &Ooorest.current_oe_user_method
    end
  end

  ActionController::Base.send :include, RequestHelper

  ActionController::Base.send :include, CurrentOEUser #TODO do it the AbstractController helper way so it's available in views


  module Paginator
    def total_count(column_name = nil, options = {})
      @klass.search_count(where_values, @context || {})
    end 

    def page(num)
      limit(default_per_page).offset(default_per_page * ([num.to_i, 1].max - 1))
    end
  end

  ::Ooor::Base.send :include, ::Kaminari::ConfigurationMethods
  ::Ooor::Relation.send :include, Kaminari::PageScopeMethods
  ::Ooor::Relation.send :include, Ooorest::Paginator

end
