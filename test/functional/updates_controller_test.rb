require 'test_helper'

class UpdatesControllerTest < ActionController::TestCase
  test "should get compare" do
    get :compare
    assert_response :success
  end

end
