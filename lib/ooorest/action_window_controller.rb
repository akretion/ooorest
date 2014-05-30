require 'json'
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
    # GET /res-partners
    # GET /res-partners.json
    def index(*args)
      extract_search_params()
      @field_names = parse_field_names
      options = {domain: @domain, fields: @field_names, context: ooor_context}
      unless params[:q].blank?
        options[:name_search] = params[:q]
      end
      @objects = @abstract_model.order(@order).page(@page).per(@per).limit(@limit).apply_finder_options(options)
      respond_to do |format|
        format.html
        format.json { render json: @objects.all, layout: false }
        format.xml { render xml: @objects.all, layout: false }
      end
    end

    # GET /res-partners/1
    # GET /res-partners/1.json
    def show(*args)
      respond_with @object
    end

    # GET /res-partners/new
    # GET /res-partners/new.json
    def new(*args)
      @object = @abstract_model.new
      respond_with @object
    end

    # GET /res-partners/1/edit
    def edit(*args)
      respond_to do |format|
        format.html # edit.html.erb        
      end
    end

    # POST /res-partners
    # POST /res-partners.json
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

    # PATCH/PUT /res-partners/1
    # PATCH/PUT /res-partners/1.json
    def update(*args)
      # NOTE: we let the before_filer do a find here because we prefer paying this
      # extra read request than writing unchanged fields to OpenERP (can trigger slow
      # computations...)
      respond_to do |format|
        if @object.update(params[@model_key], false)
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
      @object = ooor_model(@model_path.gsub('-', '.')).new({}, [], {}, true)
      @object.id = params[:id].to_i
      @object.destroy

      respond_to do |format|
        format.html { redirect_to ooorest.index_path }
        format.json { head :no_content }
      end
    end

    def search(*args) #TODO do with index with some special options to do a search instead of a read?
      extract_search_params()
      @ids = @abstract_model.search(@domain, @offset, @limit, @order, ooor_context, @count)

      respond_to do |format|
        format.html { render :xml => @ids, :layout => false }# index.html.erb
        format.json  { render :json => @ids, :layout => false }
        format.xml  { render :xml => @ids, :layout => false }
      end
    end

    def call(*args)
      method = params.delete(:method)
      arguments = extract_positional_args(params.delete(:args))
      ids = ids_from_param(params.delete(:id))
      ooor_context.keys.each do |key|
        ooor_context[key] = ooor_context[key].to_i if ooor_context[key] == ooor_context[key].to_i.to_s
      end
      if ids
        ids = [ids.to_i] unless ids.is_a? Array
        res = @abstract_model.rpc_execute(method, ids, *arguments + [ooor_context])#, context)
      else
        res = @abstract_model.rpc_execute(method, *arguments + [ooor_context]) #TODO
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

    def extract_search_params
      @domain = parse_domain(params.delete(:domain))
      @offset = params.delete(:offset) || false
      @limit = params[:limit].blank? ? 50 : params.delete(:limit).to_i
      @order = params.delete(:order) || false
      @count = params.delete(:count) || false
      @page = params[:page]
      @per = params[:per] || 50
    end

    def parse_domain(domain)
      if domain.is_a?(String)
        if domain.blank?
          return false
        else
          domain = JSON.parse(domain.gsub("(","[").gsub(")","]"))
        end
      elsif domain.is_a?(Hash) && domain.keys.first == "0" # weird way JQuery+rails pass nested arrays
        d = []
        domain.each {|k, v| d << v}
        domain = d
      end
      if domain.is_a?(Array)
        if !domain.last.is_a?(Array)
          domain = [domain]
        end

        domain.map do |item|
          if item.is_a?(Array) && item[2]
            if item[2] =~ /\A[-+]?[0-9]+\z/
              [item[0], item[1], Integer(item[2])]
            else
              item
            end
          else
            item
          end
        end
      else
        domain
      end
    end

    def extract_positional_args(args)
      if args.is_a?(String)
        unless json_args.strip[0] == '['
          json_args = "[#{json_args}]"
        end
        JSON.parse(json_args)
      else
        args
      end
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
