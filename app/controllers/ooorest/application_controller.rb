module Ooorest

  class ModelNotFound < ::StandardError
  end

  class ObjectNotFound < ::StandardError
  end

  class ApplicationController < ActionController::Base

#    before_filter :_authenticate!
#    before_filter :_authorize!

    private

    def _authenticate!
      instance_eval &Ooorest::Config.authenticate_with
    end

    def _authorize!
      instance_eval &Ooorest::Config.authorize_with
    end

    def _audit!
      instance_eval &Ooorest::Config.audit_with
    end

    def _current_user
      instance_eval &Ooorest::Config.current_user_method
    end

  end
end
