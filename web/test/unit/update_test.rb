require 'test_helper'

class UpdateTest < ActiveSupport::TestCase
  test "downloads something" do
    update = Update.new
    update.page = Page.new
    update.page.id = 1
    update.page.url = 'http://fiit.sk'
    update.download
    assert update.content != ''
    assert File.directory?("#{Rails.application.config.cache_folder}#{update.cache_folder_name}")
    assert `ls -1 #{Rails.application.config.cache_folder}#{update.cache_folder_name} | wc -l`.to_i
  end

  test "can read update from cache" do
    update = Update.new
    update.page = Page.new
    update.page.id = 1
    update.page.url = 'http://ownet.fiit.stuba.sk/'
    update.download
    assert update.content != ''
    fresh_content = update.content
    update.content = ''

    update.download true
    assert fresh_content == update.content
  end

  test "getting changed lines" do
    update = Update.new
    update.text = "foo\nbar\nbing\nbong\n"
    added_blocks, removed_blocks, moved_blocks = update.get_changed_lines "foo\nbar\nbang\nbaz\n"
    assert added_blocks == ["bing\nbong"]
    assert removed_blocks == ["bang\nbaz"]
    assert moved_blocks == []
  end

  test "blocks of changed lines" do
    update = Update.new
    update.text = "foo\nbar\nbang\nbing\nbaz\n"
    added_blocks, removed_blocks, moved_blocks = update.get_changed_lines "foo\nbar\nbing\nbong\n"
    assert added_blocks == ["bang", "baz"]
    assert removed_blocks == ["bong"]
    assert moved_blocks == []
  end

  test "moved blocks" do
    update = Update.new
    update.text = "bar\nbang\nbing\nbaz\nfoo\n"
    added_blocks, removed_blocks, moved_blocks = update.get_changed_lines "foo\nbar\nbing\nbong\n"
    assert added_blocks == ["bang", "baz"]
    assert removed_blocks == ["bong"]
    assert moved_blocks == ["foo"]
  end
end
