require 'ooorest/config/fields/base'

module Ooorest
  module Config
    module Fields
      module Types
        class Float < Ooorest::Config::Fields::Base
          # Register field type for the type loader
          Ooorest::Config::Fields::Types::register(self)
        end
      end
    end
  end
end
