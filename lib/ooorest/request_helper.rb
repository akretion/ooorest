module Ooorest
  module RequestHelper
    def ooor_model_meta
      ooor_model
    end

    def ooor_model_name(param)
      @oe_model_name = param.gsub('-', '.')
      ooor_session.class_name_from_model_key(@oe_model_name)
    end

    def ooor_context
      @ooor_context ||= params.dup().tap do |c|
        c.delete(@model_path.gsub('-', '_')) #save/create record data not part of context
        ctx = c.delete(:ooor_context)
        c.merge(ctx) if ctx.is_a?(Hash)
        c[:active_id] = c[:id]
        %w[model_name id _method controller action format _ utf8 authenticity_token commit].each {|k| c.delete(k)}
      end
    end

    def ooor_credentials
      instance_eval &Ooorest.ooor_credentials
    end

    def ooor_session
      if @ooor_session
        @ooor_session
      else
        if env['warden'] && env['warden'].authenticated?
          session_credentials = ooor_credentials
          @ooor_session = Ooor::Base.connection_handler.retrieve_connection(session_credentials)
        elsif Ooor.default_config
          @ooor_session = Ooor::Base.connection_handler.retrieve_connection(Ooor.default_config)
        else
          raise "Access Error: User isn't authenticated in Warden and no public Ooor.default_config found either"
        end
      end
    end

    def ooor_public_model(model_path=params[:model_name])
      @model_path = model_path
      @model_name = ooor_model_name(model_path)
      raise Ooorest::ModelNotFound unless (@abstract_model = Ooor::Base.connection_handler.retrieve_connection(Ooor.default_config).const_get(@model_name))
      @abstract_model
    end

    def ooor_model(model_path=params[:model_name])
      @model_path = model_path
      @model_name = ooor_model_name(model_path)
      raise Ooorest::ModelNotFound unless (@abstract_model = ooor_session.const_get(@oe_model_name))
      @abstract_model
    end

    def ooor_object(model=ooor_model, id=params[:id], fields=@fields && @fields.keys, ctx=ooor_context)
      raise Ooorest::ObjectNotFound unless (@object = model.find(id.to_i, fields: fields, context: ctx))
      @object
    end
  end
end
