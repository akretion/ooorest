require 'ooorest/config/fields/base'

module Ooorest
  module Config
    module Fields
      module Types
        class Integer < Ooorest::Config::Fields::Base
          # Register field type for the type loader
          Ooorest::Config::Fields::Types::register(self)

          register_instance_option :view_helper do
            :number_field
          end

          register_instance_option :sort_reverse? do
            serial?
          end
        end
      end
    end
  end
end
