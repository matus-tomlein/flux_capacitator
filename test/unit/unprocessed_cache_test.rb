require 'test_helper'

class UnprocessedCacheTest < ActiveSupport::TestCase
  test "can still download page after processing" do
    page = Page.create :url => 'http://ownet.fiit.stuba.sk/'

    update = Update.new
    update.page = page
    update.download
    assert update.content != ''
    update.process_cache

    update = Update.new
    update.page = page
    update.download
    assert update.content != ''
    fresh_content = update.content
    previous_folder_name = update.cache_folder_name
    update.process_cache
    assert previous_folder_name != update.cache_folder_name

    update.content = ''
    update.download 8081, true
    assert fresh_content == update.content
  end
end
