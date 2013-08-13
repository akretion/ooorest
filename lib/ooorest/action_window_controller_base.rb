#$:.push "rails/actionpack/lib"

require 'action_pack'

module Ooorest
  class ActionWindowControllerBase < ActionController::Base
    include ActionWindowController
    respond_to :html, :json, :xml

    before_filter :ooor_model_meta, :except => [:dashboard]
    before_filter :ooor_object, :only => [:show, :edit, :delete, :update, :show_in_app]

#    before_filter :_authenticate!
    before_filter :_authorize!

    helper_method :_current_user
  end
end
