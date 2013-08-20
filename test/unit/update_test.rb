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

  test "parses downloaded update" do
    update = Update.new
    update.page = Page.create :url => 'http://fiit.sk'
    update.download
    update.save

    update = Update.includes(:page).first
    update.parse_downloaded
    assert JSON.parse(File.read("#{Rails.application.config.cache_folder}parsed/#{update.cache_folder_name}.json")).count > 0
    assert update.parsed
  end

  test "parses from the web" do
    update = Update.new
    update.page = Page.new
    update.page.id = 1
    update.page.url = 'http://fiit.sk'
    update.download_and_parse
    assert JSON.parse(File.read("#{Rails.application.config.cache_folder}parsed/#{update.cache_folder_name}.json")).count > 0
    assert update.parsed
  end

  test "parses unparsed" do
    page = Page.create :url => 'http://fiit.sk'

    4.times do
      update = Update.new
      update.page = page
      update.download
      update.save
    end
    Update.parse_unparsed
    assert Update.find_all_by_parsed(true).count == 3
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

    update.download 8081, true
    assert fresh_content == update.content
  end

  test "getting changed lines" do
    update = Update.new
    update.text = "foo
bar
bing
bong
"
    added_blocks, removed_blocks, moved_blocks = update.get_changed_lines "foo
bar
bang
baz
"
    assert added_blocks == ["bing
bong"]
    assert removed_blocks == ["bang
baz"]
    assert moved_blocks == []
  end

  test "blocks of changed lines" do
    update = Update.new
    update.text = "foo
bar
bang
beng keng
bing
baz
"
    added_blocks, removed_blocks, moved_blocks = update.get_changed_lines "foo
bar
bing
bong
"
    assert added_blocks == ["bang
beng keng", "baz"]
    assert removed_blocks == ["bong"]
    assert moved_blocks == []
  end

  test "moved blocks" do
    update = Update.new
    update.text = "bar
   bang
bing
baz
foo
"
    added_blocks, removed_blocks, moved_blocks = update.get_changed_lines "foo
bar
bing
bong
"

    assert added_blocks == ["   bang", "baz"]
    assert removed_blocks == ["bong"]
    assert moved_blocks == ["foo"]
  end
end
