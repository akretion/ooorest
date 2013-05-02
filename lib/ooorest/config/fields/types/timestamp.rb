require 'ooorest/config/fields/types/datetime'

module Ooorest
  module Config
    module Fields
      module Types
        class Timestamp < Ooorest::Config::Fields::Types::Datetime
          # Register field type for the type loader
          Ooorest::Config::Fields::Types::register(self)

          @format = :long
          @i18n_scope = [:time, :formats]
          @js_plugin_options = {}
        end
      end
    end
  end
end
