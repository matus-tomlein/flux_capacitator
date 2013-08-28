require 'test_helper'

class LinksToDownloadsControllerTest < ActionController::TestCase
  test "should get take" do
    get :take
    assert_response :success
  end

end
