require 'test_helper'

module Ooorest
  class RestControllerTest < ActionController::TestCase

    test "should get index" do
      get :index, use_route: :ooorest, model_name: 'res-users', format: :json
      assert_response :success
      assert_not_nil assigns(:objects)
      assert_equal assigns(:objects)[0].login, 'admin'
    end

    test "should show" do
      get :show, use_route: :ooorest, model_name: 'res-users', id: 1, format: :json
      assert_response :success
      assert_not_nil assigns(:object)
      assert_equal assigns(:object).login, 'admin'
    end

    test "should new" do
      get :new, use_route: :ooorest, model_name: 'res-users', id: 1, format: :json
      assert_response :success
      assert_not_nil assigns(:object)
    end

  end
end
