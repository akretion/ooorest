require 'ooorest/config/fields'
require 'ooorest/config/fields/types/password'

# Register a custom field factory for properties named as password. More property
# names can be registered in Ooorest::Config::Fields::Password.column_names
# array.
#
# @see Ooorest::Config::Fields::Types::Password.column_names
# @see Ooorest::Config::Fields.register_factory
Ooorest::Config::Fields.register_factory do |parent, properties, fields|
  if [:password].include?(properties[:name])
    fields << Ooorest::Config::Fields::Types::Password.new(parent, properties[:name], properties)
    true
  else
    false
  end
end
