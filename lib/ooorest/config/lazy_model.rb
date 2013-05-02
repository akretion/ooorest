require 'ooorest/config/model'

module Ooorest
  module Config
    class LazyModel
      def initialize(entity, &block)
        @entity = entity
        @deferred_block = block
      end

      def method_missing(method, *args, &block)
        if !@model
          @model = Ooorest::Config::Model.new(@entity)
          @model.instance_eval(&@deferred_block) if @deferred_block
        end

        @model.send(method, *args, &block)
      end
    end
  end
end
