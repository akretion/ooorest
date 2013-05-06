require 'active_support/concern'

module Ooorest

#  def self.get_partial(abstract_model, model_path, view, view_type, fields)
#    "Not implemented in OOOREST, see AktOOOR instead"
#  end

  module ActionWindowController

  module Caching
    extend ActiveSupport::Concern
    include ActiveSupport::Configurable

    module ConfigMethods
      def cache_store
        config.cache_store
      end

      def cache_store=(store)
        config.cache_store = ActiveSupport::Cache.lookup_store(store)
      end

    private

      def cache_configured?
        perform_caching && cache_store
      end
    end

#    include RackDelegation
#    include AbstractController::Callbacks
    include ConfigMethods

    included do
      extend ConfigMethods

      config_accessor :perform_caching
      self.perform_caching = true if perform_caching.nil?
    end


    protected
    # Convenience accessor
    def cache(key, options = {}, &block)
      if cache_configured?
        cache_store.fetch(ActiveSupport::Cache.expand_cache_key(key, :controller), options, &block)
      else
        yield
      end
    end
  end

    include Caching

    def get_model
      @model_path = params[:model_name]
      @model_name = to_model_name(params[:model_name])
      raise Ooorest::ModelNotFound unless (@abstract_model = Ooor.connection(params).const_get(@oe_model_name))
#      raise RailsAdmin::ModelNotFound if (@model_config = @abstract_model.config).excluded?
#      @properties = @abstract_model.properties
      @view_type = {index: :tree, edit: :form, new: :form}[params["action"].to_sym] || :tree
      fvg = cache("fgv/#{@model_name}/#{@view_type}") do #TODO OE user cache wise? 
        @abstract_model.rpc_execute('fields_view_get', false, @view_type) #TODO accept specific view id/name/xml_id
      end
      @context = params.dup()
      %w[model_name _method controller action format _].each {|k| @context.delete(k)}
      @view = fvg['arch']
      @fields = fvg['fields']
      @oe_partial = Ooorest.get_partial(@abstract_model, @model_path, @view, @view_type, @fields) #TODO horrible
    end

    def get_object
#      if params[:id].index(",")
#        @ids = params[:id].gsub('[', '').gsub(']', '').split(',').map {|i| i.to_i}
#      end
      raise Ooorest::ObjectNotFound unless (@object = @abstract_model.find(params[:id], fields: @fields.keys(), context: @context)) #TODO support multiple ids
    end

    def to_model_name(param)
      @oe_model_name = param.gsub('-', '.')
      Ooor::Base.class_name_from_model_key(@oe_model_name)
    end

    def params
      @local_params || super
    end


    # GET /res_partners
    # GET /res_partners.json
    def index(args=nil)
      @local_params = args
      @domain = eval((params.delete(:domain) || "[]").gsub("(","[").gsub(")","]"))
      @offset = params.delete(:offset) || false
      @limit = params.delete(:limit) || false
      @order = params.delete(:order) || false
      @count = params.delete(:count) || false
      @field_names = params.delete(:fields) || @fields.keys
      #TODO find ids using pagination
      @objects = @abstract_model.find(:all, :domain=>@domain, :fields=>@field_names, :context => @context)#TODO plug on read?

      respond_to do |format|
        format.html # index.html.erb
        format.json  { render :json => @objects, :layout => false }
        format.xml  { render :xml => @objects, :layout => false }
      end
    end

    # GET /res_partners/1
    # GET /res_partners/1.json
    def show(args=nil)
      @local_params = args
      respond_to do |format|
        format.html # show.html.erb
        format.xml { render xml: @object }
        format.json { render json: @object }
      end
    end

    # GET /res_partners/new
    # GET /res_partners/new.json
    def new(args=nil)
      @local_params = args
      @object = @abstract_model.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @object }
      end
    end

    # GET /res_partners/1/edit
    def edit(args=nil)
      @local_params = args
      respond_to do |format|
        format.html # edit.html.erb        
      end
    end

    # POST /res_partners
    # POST /res_partners.json
    def create(args=nil)
      @local_params = args
      respond_to do |format|
        if @object.save
          format.html { redirect_to @object, notice: 'Res partner was successfully created.' }
          format.json { render json: @object, status: :created, location: @res_partner }
        else
          format.html { render action: "new" }
          format.json { render json: @object.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /res_partners/1
    # PUT /res_partners/1.json
    def update(args=nil)
      @local_params = args
      respond_to do |format|
        if @object.update_attributes(params[:res_partner])
          format.html { redirect_to @object, notice: 'Res partner was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @object.errors, status: :unprocessable_entity }
        end
      end
    end

#TODO TODO TODO FIXME FIXME FIXME
  def search(args=nil)
    @local_params = args
    @domain = eval((params.delete(:domain) || "[]").gsub("(","[").gsub(")","]"))
    @offset = params.delete(:offset) || false
    @limit = params.delete(:limit) || false
    @order = params.delete(:order) || false
    @count = params.delete(:count) || false
    @context = context_from_params(params)
    @ids = model_class.search(@domain, @offset, @limit, @order, @context, @count)

    respond_to do |format|
      format.html { render :xml => @ids, :layout => false }# index.html.erb
      format.json  { render :json => @ids, :layout => false }
      format.xml  { render :xml => @ids, :layout => false }
    end
  end

  def call(args=nil)
    @local_params = args
    @context = context_from_params(params)
    method =  @context.delete(:method)
    arguments = eval("[" + @context.delete(:param_string) + "]")
    #@context.delete(:args)
    ids = ids_from_param(@context.delete(:id))
    @context.keys.each do |key|
      @context[key] = @context[key].to_i if @context[key] == @context[key].to_i.to_s
    end
    if ids
      ids = [ids.to_i] unless ids.is_a? Array
      res = model_class.rpc_execute(method, ids, *arguments + [@context])#, @context)
    else
      res = model_class.rpc_execute(method, *arguments + [@context]) #TODO
    end
    respond_to do |format|
      format.html { render :xml => res, :layout => false }# show.html.erb
      format.xml  { render :xml => res, :layout => false }
      format.json  { render :json => res, :layout => false }
    end
  end

    def copy(args=nil)
    @local_params = args
      render :json => "TODO", :layout => false
    end

    def wkf_action(args=nil)
    @local_params = args
      render :json => "TODO", :layout => false
    end

    def on_change(args=nil)
    @local_params = args
      render :json => "TODO", :layout => false
    end

  end
end
