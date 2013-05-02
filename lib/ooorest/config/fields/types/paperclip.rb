require 'ooorest/config/fields/base'
require 'ooorest/config/fields/types/file_upload'

module Ooorest
  module Config
    module Fields
      module Types
        # Field type that supports Paperclip file uploads
        class Paperclip < Ooorest::Config::Fields::Types::FileUpload
          Ooorest::Config::Fields::Types.register(self)

          register_instance_option :delete_method do
            "delete_#{name}" if bindings[:object].respond_to?("delete_#{name}")
          end

          register_instance_option :thumb_method do
            @styles ||= bindings[:object].send(name).styles.map(&:first)
            @thumb_method ||= @styles.find{|s| [:thumb, 'thumb', :thumbnail, 'thumbnail'].include?(s)} || @styles.first || :original
          end

          def resource_url(thumb = false)
            value.try(:url, (thumb || :original))
          end
        end
      end
    end
  end
end
