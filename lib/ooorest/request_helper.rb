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
        c[:active_id] = c[:id]
        %w[model_name id _method controller action format _].each {|k| c.delete(k)}
      end
    end

    def get_session_credentials
      {ooor_user_id: 1, ooor_password: 'admin2', ooor_database: 'rails2'} #TODO deal with current_user
    end

    def connection
      if @connection
        @connection
      else
        session_credentials = get_session_credentials
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
