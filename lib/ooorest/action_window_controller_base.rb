#$:.push "rails/actionpack/lib"

require 'action_pack'

module Ooorest
  class ActionWindowControllerBase < ActionController::Base
    include ActionWindowController
    respond_to :html, :json, :xml

    before_action :ooor_model_meta, :except => [:dashboard]
    before_action :ooor_object, :only => [:show, :edit, :update, :show_in_app]

    before_action :_authenticate! if Ooor.default_config[:authenticate_ooorest]
    before_action :_authorize!

    helper_method :_current_user
  end
end
