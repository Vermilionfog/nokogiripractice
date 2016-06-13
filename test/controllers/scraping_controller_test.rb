require 'test_helper'

class ScrapingControllerTest < ActionController::TestCase
  test "should get testing_page" do
    get :testing_page
    assert_response :success
  end

end
