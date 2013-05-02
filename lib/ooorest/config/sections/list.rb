require 'ooorest/config/sections/base'

module Ooorest
  module Config
    module Sections
      # Configuration of the list view
      class List < Ooorest::Config::Sections::Base
        register_instance_option :filters do
          []
        end

        # Number of items listed per page
        register_instance_option :items_per_page do
          Ooorest::Config.default_items_per_page
        end

        register_instance_option :sort_by do
          parent.abstract_model.primary_key
        end

        register_instance_option :sort_reverse? do
          true # By default show latest first
        end
      end
    end
  end
end
