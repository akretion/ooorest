require 'ooorest/config/proxyable'
require 'ooorest/config/configurable'
require 'ooorest/config/has_fields'
require 'ooorest/config/has_groups'

module Ooorest
  module Config
    module Sections
      # Configuration of the show view for a new object
      class Base
        include Ooorest::Config::Proxyable
        include Ooorest::Config::Configurable

        include Ooorest::Config::HasFields
        include Ooorest::Config::HasGroups

        attr_reader :abstract_model
        attr_reader :parent, :root

        def initialize(parent)
          @parent = parent
          @root = parent.root

          @abstract_model = root.abstract_model
        end

        def inspect
          "#<#{self.class.name} #{
            instance_variables.map do |v|
              value = instance_variable_get(v)
              if [:@parent, :@root, :@abstract_model].include? v
                if value.respond_to? :name
                  "#{v}=#{value.name.inspect}"
                else
                  "#{v}=#{value.class.name}"
                end
              else
                "#{v}=#{value.inspect}"
              end
            end.join(", ")
          }>"
        end
      end
    end
  end
end
