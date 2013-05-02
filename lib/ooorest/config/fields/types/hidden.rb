require 'ooorest/config/fields/base'

module Ooorest
  module Config
    module Fields
      module Types
        class Hidden < Ooorest::Config::Fields::Base
          Ooorest::Config::Fields::Types::register(self)

          register_instance_option :view_helper do
            :hidden_field
          end

          register_instance_option :label do
            false
          end

          register_instance_option :help do
            false
          end


        end
      end
    end
  end
end
