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

    end
  end

  include OoorestConfig

  AbstractController::Base.send :include, RequestHelper

  class ActionController::Base
    helper RequestHelper
    def current_user
      user = super
      class << user
        include Ooorest::User
      end
      user.set_env(env)
      user
    end
  end

  module Paginator
    def total_count(column_name = nil, options = {})
      @klass.search_count(where_values, @ooor_context || {})
    end 

    def page(num)
      limit(default_per_page).offset(default_per_page * ([num.to_i, 1].max - 1))
    end
  end

  ::Ooor::Base.send :include, ::Kaminari::ConfigurationMethods
  ::Ooor::Relation.send :include, Kaminari::PageScopeMethods
  ::Ooor::Relation.send :include, Ooorest::Paginator

end
