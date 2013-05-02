require "ooorest/engine"
require 'ooorest/abstract_model'
require 'ooorest/config'
require 'ooorest/support/core_extensions'

module Ooorest
  # Setup Ooorest
  #
  # Given the first argument is a model class, a model class name
  # or an abstract model object proxies to model configuration method.
  #
  # If only a block is passed it is stored to initializer stack to be evaluated
  # on first request in production mode and on each request in development. If
  # initialization has already occured (in other words RailsAdmin.setup has
  # been called) the block will be added to stack and evaluated at once.
  #
  # Otherwise returns RailsAdmin::Config class.
  #
  # @see Ooorest::Config
  def self.config(entity = nil, &block)
    if entity
      Ooorest::Config.model(entity, &block)
    elsif block_given? && ENV['SKIP_RAILS_ADMIN_INITIALIZER'] != "true"
      block.call(Ooorest::Config)
    else
      Ooorest::Config
    end
  end
end
