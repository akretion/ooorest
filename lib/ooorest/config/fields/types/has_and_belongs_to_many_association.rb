require 'ooorest/config/fields/types/has_many_association'

module Ooorest
  module Config
    module Fields
      module Types
        class HasAndBelongsToManyAssociation < Ooorest::Config::Fields::Types::HasManyAssociation
          # Register field type for the type loader
          Ooorest::Config::Fields::Types::register(self)
        end
      end
    end
  end
end
