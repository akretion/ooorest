require_dependency "ooorest/application_controller"
require_dependency "ooorest/action_window_controller"

module Ooorest
  class RestController < ApplicationController
    include Ooorest::ActionWindowController
    layout 'application' #TODO

    before_filter :get_model, :except => [:dashboard]
    before_filter :get_object, :only => [:show, :edit, :delete,:show_in_app]
  end
end
