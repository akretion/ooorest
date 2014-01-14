require 'test_helper'

module Ooorest
  module RequestHelper
    def ooor_session_for_tests
      Ooor.default_session
    end

    alias_method :ooor_session, :ooor_session_for_tests
  end


  class RestControllerTest < ActionController::TestCase

    test "should get index" do
      get :index, use_route: :ooorest, model_name: 'res-users', format: :json
      assert_response :success
      assert_not_nil assigns(:objects)
      assert_equal 'admin', assigns(:objects)[0].login
      assert_equal 'admin', JSON.parse(response.body)[0]['login']
    end

    test "should filter on index" do
      get :index, use_route: :ooorest, model_name: 'res-users', format: :json, domain: '["login", "=", "demo"]'
      assert_response :success
      assert_not_nil assigns(:objects)
      assert_equal 'demo', assigns(:objects)[0].login
      assert_equal 'demo', JSON.parse(response.body)[0]['login']
    end

    test "should load only specified fields" do
      get :index, use_route: :ooorest, model_name: 'res-users', format: :json, fields: 'login,company_id'
      assert_response :success
      assert_nil JSON.parse(response.body)[0]['name']
    end

    test "should show" do
      get :show, use_route: :ooorest, model_name: 'res-users', id: 1, format: :json
      assert_response :success
      assert_not_nil assigns(:object)
      assert_equal 'admin', assigns(:object).login
      assert_equal 'admin', JSON.parse(response.body)['login']
    end

    test "should new" do
      get :new, use_route: :ooorest, model_name: 'res-users', id: 1, format: :json
      assert_response :success
      assert_not_nil assigns(:object)
      assert_equal 'en_US', JSON.parse(response.body)['lang'] #default value
    end

    test "should search" do
      get :search, use_route: :ooorest, model_name: 'res-users', format: :json, domain: '["login", "=", "demo"]'
      assert_response :success
      assert_not_nil assigns(:ids)
    end


  end
end
