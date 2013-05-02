module Ooorest
  class ModelNotFound < ::StandardError
  end

  class ObjectNotFound < ::StandardError
  end

  class ApplicationController < ActionController::Base

#    before_filter :_authenticate!
#    before_filter :_authorize!

    def get_model
      @model_name = to_model_name(params[:model_name])
      raise Ooorest::ModelNotFound unless (@abstract_model = Ooor::Ooor.default_ooor.const_get(@oe_model_name))
#      raise RailsAdmin::ModelNotFound if (@model_config = @abstract_model.config).excluded?
#      @properties = @abstract_model.properties
      @view_type = {index: :tree, edit: :form}[params["action"].to_sym] || 'tree'
      fvg = cache("fgv/#{@model_name}/#{@view_type}") do #TODO OE user cache wise? 
        @abstract_model.rpc_execute('fields_view_get', false, @view_type) #TODO accept specific view id/name/xml_id
      end
      @context = params.dup()
      %w[model_name _method controller action format _].each {|k| @context.delete(k)}
      @view = fvg['arch']
      @fields = fvg['fields']
    end

    def get_object
#      if params[:id].index(",")
#        @ids = params[:id].gsub('[', '').gsub(']', '').split(',').map {|i| i.to_i}
#      end
      raise Ooorest::ObjectNotFound unless (@object = @abstract_model.find(params[:id], fields: @fields.keys(), context: @contexti)) #TODO support multiple ids
    end

    def to_model_name(param)
      @oe_model_name = param.gsub('_', '.')
      Ooor::OpenObjectResource.class_name_from_model_key(@oe_model_name)
    end

    private

    def _authenticate!
      instance_eval &Ooorest::Config.authenticate_with
    end

    def _authorize!
      instance_eval &Ooorest::Config.authorize_with
    end

    def _audit!
      instance_eval &Ooorest::Config.audit_with
    end

    def _current_user
      instance_eval &Ooorest::Config.current_user_method
    end

  end
end
