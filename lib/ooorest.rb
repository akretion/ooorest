require 'active_support'
require 'ooorest/engine'
require 'ooorest/action_window_controller'

module Ooorest

  DEFAULT_AUTHENTICATION = Proc.new do
    request.env['warden'].try(:authenticate!)
  end

  DEFAULT_ATTR_ACCESSIBLE_ROLE = Proc.new { :default }

  DEFAULT_AUTHORIZE = Proc.new {}

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

    end
  end

  include OoorestConfig
end
