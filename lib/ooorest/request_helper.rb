require 'ooor/errors'

module Ooorest
  module RequestHelper
    def ooor_model_meta
      ooor_model
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

    def ooor_session
      env['ooor']['ooor_session']
    end

    def ooor_public_session
      Ooor.default_session
    end

    def ooor_default_model(model_path=params[:model_name])
      @model_path = model_path
      @model_name = model_path.gsub('-', '.')
      @model_key = model_path.gsub('-', '_')
      raise Ooorest::ModelNotFound unless (@abstract_model = ooor_public_session.const_get(@model_name))
      @abstract_model
    end

    def ooor_model(model_path=params[:model_name])
      @model_path = model_path
      @model_name = model_path.gsub('-', '.')
      @model_key = model_path.gsub('-', '_')
      raise Ooorest::ModelNotFound unless (@abstract_model = ooor_session.const_get(@model_name))
      @abstract_model
    rescue Ooor::UnAuthorizedError
      render :status => :unauthorized, :text => "Unauthorized"
    end

    def ooor_object(model=ooor_model, id=params[:id], fields=@fields && @fields.keys, ctx=ooor_context)
      raise Ooorest::ObjectNotFound unless (@object = model.find(id.to_i, fields: fields, context: ctx))
      @object
    rescue Ooor::UnAuthorizedError
      render :status => :unauthorized, :text => "Unauthorized"
    end
  end


  module User
    include RequestHelper
    def set_env(env)
      @env = env
    end

    def ooor_session
      @env['ooor']['ooor_session']
    end

    def partner_id
      child_candidate = ooor_model('res.partner').search([['email', '=', email], ['parent_id', '!=', false]])[0]
      child_candidate || legal_partner_id
    end

    def partner
      ooor_model('res.partner').find(partner_id)
    end

    def legal_partner_id
      ooor_model('res.partner').search(['&', '|', ['email', '=', email], ['is_company', '=', true], ['parent_id', '=', false]])[0]
    end

    def legal_partner
      ooor_model('res.partner').find(legal_partner_id)
    end

    def user_id
      ooor_model('res.users').search(['email', '=', email])[0]
    end

    def user
      ooor_model('res.users').find(user_id)
    end
  end
end
