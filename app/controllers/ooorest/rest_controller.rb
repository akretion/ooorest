require_dependency "ooorest/application_controller"
require_dependency "ooorest/action_window_controller"

module Ooorest
  class RestController < ApplicationController
    include Ooorest::ActionWindowController
#    layout :get_layout
    layout 'application'

    before_filter :get_model, :except => Ooorest::Config::Actions.all(:root).map(&:action_name)
    before_filter :get_object, :only => Ooorest::Config::Actions.all(:member).map(&:action_name)
    #TODO authenticate user and use it for requests

  end
end
