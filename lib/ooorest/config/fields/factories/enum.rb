require 'ooorest/config/fields'
require 'ooorest/config/fields/types/enum'

Ooorest::Config::Fields.register_factory do |parent, properties, fields|
  if parent.abstract_model.model.respond_to?("#{properties[:name]}_enum") || parent.abstract_model.model.method_defined?("#{properties[:name]}_enum")
    fields << Ooorest::Config::Fields::Types::Enum.new(parent, properties[:name], properties)
    true
  else
    false
  end
end
