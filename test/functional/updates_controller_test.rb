require 'test_helper'

class UpdatesControllerTest < ActionController::TestCase
  test "should load image from cache" do
    page = Page.create :url => 'http://ownet.fiit.stuba.sk/'

    update = Update.new
    update.page = page
    update.download
    update.save

    get :image, { 'id' => update.id }
    assert_redirected_to "/updates-screenshots/#{update.id}.png"
    assert File.exist?(Rails.public_path + "/updates-screenshots/#{update.id}.png")
  end
end
