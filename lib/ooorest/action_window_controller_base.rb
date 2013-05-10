#$:.push "rails/actionpack/lib"

require 'action_pack'

module Ooorest

  class ModelNotFound < ::StandardError
  end

  class ObjectNotFound < ::StandardError
  end

  class ActionWindowControllerBase < ActionController::Base
    include ActionWindowController

    before_filter :get_model_meta, :except => [:dashboard]
    before_filter :get_object, :only => [:show, :edit, :delete,:show_in_app]

    before_filter :_authenticate!
    before_filter :_authorize!

    private

    def _authenticate!
      instance_eval &Ooorest.authenticate_with
    end

    def _authorize!
      instance_eval &Ooorest.authorize_with
    end

    def _audit!
      instance_eval &Ooorest.audit_with
    end

    def _current_user
      instance_eval &Ooorest.current_user_method
    end

  end
end
