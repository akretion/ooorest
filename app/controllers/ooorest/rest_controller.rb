#require_dependency "ooorest/application_controller"
#require_dependency "ooorest/action_window_controller"
require "ooorest/action_window_controller"

module Ooorest
  class RestController < ApplicationController
    layout 'application' #TODO
  end
end
