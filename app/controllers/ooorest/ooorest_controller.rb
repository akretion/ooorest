require_dependency "ooorest/application_controller"

module Ooorest
  class OoorestController < ApplicationController
    #TODO include helpers
    layout :get_layout

    before_filter :get_model, :except => Ooorest::Config::Actions.all(:root).map(&:action_name)
    before_filter :get_object, :only => Ooorest::Config::Actions.all(:member).map(&:action_name)
    #TODO authenticate user and use it for requests

    # GET /res_partners
    # GET /res_partners.json
    def index
      @domain = eval((params.delete(:domain) || "[]").gsub("(","[").gsub(")","]"))
      @offset = params.delete(:offset) || false
      @limit = params.delete(:limit) || false
      @order = params.delete(:order) || false
      @count = params.delete(:count) || false
      @field_names = params.delete(:fields) || @fields.keys
      #TODO find ids using pagination
      @objects = @abstract_model.find(:all, :domain=>@domain, :fields=>@field_names, :context => @context)#TODO plug on read?

      respond_to do |format|
        format.html { render :xml => @objects, :layout => false }# index.html.erb
        format.json  { render :json => @objects, :layout => false }
        format.xml  { render :xml => @objects, :layout => false }
      end
    end

    # GET /res_partners/1
    # GET /res_partners/1.json
    def show
      respond_to do |format|
        format.html # show.html.erb
        format.xml { render xml: @object }
        format.json { render json: @object }
      end
    end

    # GET /res_partners/new
    # GET /res_partners/new.json
    def new
      @object = @abstract_model.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @object }
      end
    end

    # GET /res_partners/1/edit
    def edit
    end

    # POST /res_partners
    # POST /res_partners.json
    def create
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
    def update
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
  def search
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

  def call
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

    def copy
      render :json => "TODO", :layout => false
    end

    def wkf_action
      render :json => "TODO", :layout => false
    end

    def on_change
      render :json => "TODO", :layout => false
    end


  end
end
