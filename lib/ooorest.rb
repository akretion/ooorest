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

  DEFAULT_CURRENT_USER = Proc.new do
    request.env["warden"].try(:user) || respond_to?(:current_user) && current_user
  end

  DEFAULT_OE_CREDENTIALS = Proc.new do #TODO
    raise "_current_oe_credentials is not implemented here, your app config should provide this specific implementation!"
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

      def current_user_method(&block)
        @current_user = block if block
        @current_user || DEFAULT_CURRENT_USER
      end

      def current_oe_credentials(&block)
        @oe_credentials = block if block
        @oe_credentials || DEFAULT_OE_CREDENTIALS
      end

    end
  end

  include OoorestConfig

  class AbstractController::Base
    include RequestHelper
    def _current_oe_credentials
      instance_eval &Ooorest.current_oe_credentials
    end
  end

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
