require 'ooorest/config/fields/types/datetime'

module Ooorest
  module Config
    module Fields
      module Types
        class Time < Ooorest::Config::Fields::Types::Datetime
          # Register field type for the type loader
          Ooorest::Config::Fields::Types::register(self)

          @format = :short
          @i18n_scope = [:time, :formats]
          @js_plugin_options = {
            "showDate" => false,
          }

          # Register field type for the type loader
          Ooorest::Config::Fields::Types::register(self)

          def parse_input(params)
            params[name] = self.class.normalize(params[name], localized_time_format) if params[name].present?
          end

          # Parse normalized date (time) strings using UTC
          def self.parse_date_string(date_string)
            ::DateTime.parse(date_string)
          end

          register_instance_option :strftime_format do
            (localized_format.include? "%p") ? "%I:%M %p" : "%H:%M"
          end
        end
      end
    end
  end
end
