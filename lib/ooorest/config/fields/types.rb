require 'active_support/core_ext/string/inflections'
require 'ooorest/config/fields'
require 'ooorest/config/fields/association'

module Ooorest
  module Config
    module Fields
      module Types
        @@registry = {}

        def self.load(type)
          @@registry[type.to_sym] or raise "Unsupported field datatype: #{type}"
        end

        def self.register(type, klass = nil)
          if klass == nil && type.kind_of?(Class)
            klass = type
            type = klass.name.to_s.demodulize.underscore
          end
          @@registry[type.to_sym] = klass
        end

        require 'ooorest/config/fields/types/all'
      end
    end
  end
end
