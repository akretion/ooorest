require 'ooorest/config/fields'
require 'ooorest/config/fields/types'
require 'ooorest/config/fields/types/password'

# Register a custom field factory for devise model
Ooorest::Config::Fields.register_factory do |parent, properties, fields|
  if properties[:name] == :encrypted_password
    extensions = [:password_salt, :reset_password_token, :remember_token]
    model = parent.abstract_model.model

    fields << Ooorest::Config::Fields::Types.load(:password).new(parent, :password, properties)
    fields << Ooorest::Config::Fields::Types.load(:password).new(parent, :password_confirmation, properties)
    extensions.each do |ext|
      properties = parent.abstract_model.properties.find {|p| ext == p[:name]}
      if properties
        unless field = fields.find{ |f| f.name == ext }
          Ooorest::Config::Fields.default_factory.call(parent, properties, fields)
          field = fields.last
        end
        field.hide
      end
    end
    true
  else
    false
  end
end
