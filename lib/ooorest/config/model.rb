require 'ooorest/config'
require 'ooorest/config/proxyable'
require 'ooorest/config/configurable'
require 'ooorest/config/hideable'
require 'ooorest/config/has_groups'
require 'ooorest/config/fields/group'
require 'ooorest/config/fields'
require 'ooorest/config/has_fields'
require 'ooorest/config/sections'
require 'ooorest/config/actions'


module Ooorest
  module Config
    # Model specific configuration object.
    class Model
      include Ooorest::Config::Proxyable
      include Ooorest::Config::Configurable
      include Ooorest::Config::Hideable
      include Ooorest::Config::Sections

      attr_reader :abstract_model
      attr_accessor :groups
      attr_reader :parent, :root

      def initialize(entity)
        @parent = nil
        @root = self

        @abstract_model = begin
          if entity.kind_of?(Ooorest::AbstractModel)
            entity
          elsif entity.kind_of?(Class) || entity.kind_of?(String) || entity.kind_of?(Symbol)
            Ooorest::AbstractModel.new(entity)
          else
            Ooorest::AbstractModel.new(entity.class)
          end
        end
        @groups = [ Ooorest::Config::Fields::Group.new(self, :default).tap {|g| g.label{I18n.translate("admin.form.basic_info")} } ]
      end

      def excluded?
        @excluded ||= !Ooorest::AbstractModel.all.map(&:model_name).include?(abstract_model.try(:model_name))
      end

      def object_label
        bindings[:object].send object_label_method
      end

      # The display for a model instance (i.e. a single database record).
      # Unless configured in a model config block, it'll try to use :name followed by :title methods, then
      # any methods that may have been added to the label_methods array via Configuration.
      # Failing all of these, it'll return the class name followed by the model's id.
      register_instance_option :object_label_method do
        @object_label_method ||= Config.label_methods.find { |method| (@dummy_object ||= abstract_model.model.new).respond_to? method } || :ooorest_default_object_label_method
      end

      register_instance_option :label do
        (@label ||= {})[::I18n.locale] ||= abstract_model.model.model_name.human(:default => abstract_model.model.model_name.demodulize.underscore.humanize)
      end

      register_instance_option :label_plural do
        (@label_plural ||= {})[::I18n.locale] ||= abstract_model.model.model_name.human(:count => 'other', :default => label.pluralize)
      end

      def pluralize(count)
        count == 1 ? label : label_plural
      end

      register_instance_option :weight do
        0
      end

      # parent node in navigation/breadcrumb
      register_instance_option :parent do
        @parent_model ||= begin
          (klass = abstract_model.model.superclass).to_s.in?(['Object', 'BasicObject', 'ActiveRecord::Base']) ? nil : klass
        end
      end

      register_instance_option :navigation_label do
         @navigation_label ||= (parent_module = abstract_model.model.parent) != Object ? parent_module.to_s : nil
      end

      register_instance_option :navigation_icon do
        nil
      end

      # Act as a proxy for the base section configuration that actually
      # store the configurations.
      def method_missing(m, *args, &block)
        self.send(:base).send(m, *args, &block)
      end

      def inspect
        "#<#{self.class.name}[#{abstract_model.model.name}] #{
          instance_variables.map do |v|
            value = instance_variable_get(v)
            if [:@parent, :@root].include? v
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
