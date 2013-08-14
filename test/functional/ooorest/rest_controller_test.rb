require 'test_helper'

module Ooorest
  class RestControllerTest < ActionController::TestCase

    test "should get index" do
      get :index, use_route: :ooorest, model_name: 'res-users', format: :json
      assert_response :success
      assert_not_nil assigns(:objects)
      assert_equal 'admin', assigns(:objects)[0].login
      assert_equal 'admin', JSON.parse(response.body)[0]['login']
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

  end
end
