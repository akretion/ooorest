module Ooorest
  module RequestHelper
    def get_model_meta
      get_model
    end

    def to_model_name(param)
      @oe_model_name = param.gsub('-', '.')
      connection.class_name_from_model_key(@oe_model_name)
    end

    def context
      @context ||= params.dup().tap do |c|
        c.delete(@model_path.gsub('-', '_')) #save/create record data not part of context
        ctx = c.delete(:context)
        c.merge(ctx) if ctx.is_a?(Hash)
        c[:active_id] = c[:id]
        %w[model_name id _method controller action format _ utf8 authenticity_token commit].each {|k| c.delete(k)}
      end
    end

    def connection
      if @connection
        @connection
      else
        session_credentials = _current_oe_credentials
        session_credentials.merge(params.slice(:ooor_user_id, :ooor_username, :ooor_password, :ooor_database)) #TODO dangerous?
        @connection = Ooor::Base.connection_handler.retrieve_connection(session_credentials)
      end
    end

    def get_model
      @model_path = params[:model_name]
      @model_name = to_model_name(params[:model_name])
      raise Ooorest::ModelNotFound unless (@abstract_model = connection.const_get(@oe_model_name))
    end

    def get_object
#       if params[:id].index(",")
#         @ids = params[:id].gsub('[', '').gsub(']', '').split(',').map {|i| i.to_i}
#       end
      raise Ooorest::ObjectNotFound unless (@object = @abstract_model.find(params[:id], fields: @fields && @fields.keys, context: context)) #TODO support multiple ids
    end
  end
end
