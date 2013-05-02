require 'active_support/core_ext/string/inflections'
require 'ooorest/config/sections/base'
require 'ooorest/config/sections/edit'
require 'ooorest/config/sections/update'
require 'ooorest/config/sections/create'
require 'ooorest/config/sections/nested'
require 'ooorest/config/sections/modal'
require 'ooorest/config/sections/list'
require 'ooorest/config/sections/export'
require 'ooorest/config/sections/show'


module Ooorest
  module Config
    # Sections describe different views in the Ooorest engine. Configurable sections are
    # list and navigation.
    #
    # Each section's class object can store generic configuration about that section (such as the
    # number of visible tabs in the main navigation), while the instances (accessed via model
    # configuration objects) store model specific configuration (such as the visibility of the
    # model).
    module Sections
      def self.included(klass)
        # Register accessors for all the sections in this namespace
        constants.each do |name|
          section = "Ooorest::Config::Sections::#{name}".constantize
          name = name.to_s.underscore.to_sym
          klass.send(:define_method, name) do |&block|
            @sections = {} unless @sections
            @sections[name] = section.new(self) unless @sections[name]
            @sections[name].instance_eval &block if block
            @sections[name]
          end
        end
      end
    end
  end
end

