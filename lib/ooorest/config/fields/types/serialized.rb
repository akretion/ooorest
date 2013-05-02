require 'ooorest/config/fields/types/text'

module Ooorest
  module Config
    module Fields
      module Types
        class Serialized < Ooorest::Config::Fields::Types::Text
          # Register field type for the type loader
          Ooorest::Config::Fields::Types::register(self)

          register_instance_option :formatted_value do
            YAML.dump(value)
          end

          def parse_input(params)
            if params[name].is_a?(::String)
              params[name] = (params[name].blank? ? nil : (YAML.safe_load(params[name]) || nil))
            end
          end
        end
      end
    end
  end
end
