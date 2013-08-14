require 'active_support/concern'
require 'active_support/dependencies/autoload'
require 'ooor'
require 'ooor/base'

require 'action_controller'
require 'ooorest/request_helper'

module Ooorest
  class ModelNotFound < ::StandardError
  end

  class ObjectNotFound < ::StandardError
  end

  module ActionWindowController
    # GET /res_partners
    # GET /res_partners.json
    def index(*args)
      @domain = eval((params.delete(:domain) || "[]").gsub("(","[").gsub(")","]")) #FIXME remove that eval!
      @offset = params.delete(:offset) || false
      @limit = params[:limit].blank? ? 50 : params.delete(:limit).to_i
      @order = params.delete(:order) || false
      @count = params.delete(:count) || false
      @field_names = parse_field_names
      @page = params[:page]
      @per = params[:per] || 50
      options = {:domain=>@domain, :fields=>@field_names, :context => ooor_context}
      unless params[:q].blank?
        options[:name_search] = params[:q]
      end
      @objects = @abstract_model.order(@order).page(@page).per(@per).limit(@limit).apply_finder_options(options)
      respond_to do |format|
        format.html
        format.json { render :json => @objects.all, :layout => false }
        format.xml { render :xml => @objects.all, :layout => false }
      end
    end

    # GET /res_partners/1
    # GET /res_partners/1.json
    def show(*args)
      respond_with @object
    end

    # GET /res_partners/new
    # GET /res_partners/new.json
    def new(*args)
      @object = @abstract_model.new
      respond_with @object
    end

    # GET /res_partners/1/edit
    def edit(*args)
      respond_to do |format|
        format.html # edit.html.erb        
      end
    end

    # POST /res_partners
    # POST /res_partners.json
    def create(*args)
      respond_to do |format|
        @object = @abstract_model.new(params[@model_path.gsub('-', '_')])
        if @object.save
          format.html { redirect_to ooorest.index_path, notice: "successfully creation" }
          format.json { render json: @object, status: :created, location: @res_partner }
        else
          format.html { render action: "new" }
          format.json { render json: @object.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /res_partners/1
    # PUT /res_partners/1.json
    def update(*args)
      respond_to do |format|
        if @object.update_attributes(params[@model_path.gsub('-', '_')]) #NOTE may be use just write on id without find before?
          format.html { redirect_to ooorest.index_path, notice: "successfully update" }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @object.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /posts/1
    # DELETE /posts/1.json
    def destroy
      @object = @abstract_model.find(params[:id])
      @object.destroy

      respond_to do |format|
        format.html { redirect_to ooorest.index_path }
        format.json { head :no_content }
      end
    end


#TODO TODO TODO FIXME FIXME FIXME
  def search(*args)
    @domain = eval((params.delete(:domain) || "[]").gsub("(","[").gsub(")","]"))
    @offset = params.delete(:offset) || false
    @limit = params.delete(:limit) || false
    @order = params.delete(:order) || false
    @count = params.delete(:count) || false
    @ids = model_class.search(@domain, @offset, @limit, @order, ooor_context, @count)

    respond_to do |format|
      format.html { render :xml => @ids, :layout => false }# index.html.erb
      format.json  { render :json => @ids, :layout => false }
      format.xml  { render :xml => @ids, :layout => false }
    end
  end

  def call(*args)
    method = ooor_context.delete(:method)
    arguments = eval("[" + ooor_context.delete(:param_string) + "]")
    #ooor_context.delete(:args)
    ids = ids_from_param(ooor_context.delete(:id))
    ooor_context.keys.each do |key|
      ooor_context[key] = ooor_context[key].to_i if ooor_context[key] == ooor_context[key].to_i.to_s
    end
    if ids
      ids = [ids.to_i] unless ids.is_a? Array
      res = model_class.rpc_execute(method, ids, *arguments + [ooor_context])#, context)
    else
      res = model_class.rpc_execute(method, *arguments + [ooor_context]) #TODO
    end
    respond_to do |format|
      format.html { render :xml => res, :layout => false }# show.html.erb
      format.xml  { render :xml => res, :layout => false }
      format.json  { render :json => res, :layout => false }
    end
  end

    def copy(*args)
      render :json => "TODO", :layout => false
    end

    def wkf_action(*args)
      render :json => "TODO", :layout => false
    end

    def on_change(*args)
      render :json => "TODO", :layout => false
    end

    private

    def _authenticate!
      instance_eval &Ooorest.authenticate_with
    end

    def _authorize!
      instance_eval &Ooorest.authorize_with
    end

    def _audit!
      instance_eval &Ooorest.audit_with
    end

    def _current_user
      instance_eval &Ooorest.current_user_method
    end

    def parse_field_names
      if @fields
        @fields.keys
      elsif !params[:fields].blank?
        fields = params.delete(:fields)
        if fields.is_a? String
          fields.split(",")
        elsif fields.is_a? Array
          fields
        end
      end
    end

  end
end
