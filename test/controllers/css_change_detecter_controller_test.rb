require 'test_helper'

class CssChangeDetecterControllerTest < ActionController::TestCase
  test "should get display" do
    get :display
    assert_response :success
  end

  test "should get edit" do
    get :edit
    assert_response :success
  end

end
