require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test "choosing tracked pages" do
    100.times do |i|
      page = Page.create :url => "http://#{i}.com"
      (Random.rand(3) + 1).times do
        PageRanking.create :page => page, :google_rank => Random.rand(12)
      end
    end
    page = Page.create :url => "http://winner.com", :num_failed_accesses => 3
    PageRanking.create :page => page, :google_rank => 15

    Page.retrack_websites_by_rank 50

    assert Page.find_all_by_track(true).count == 50
    assert Page.where(:num_failed_accesses => 3).first.track == false
    assert PlannedUpdate.from_pages(Page.where(:track => true)).count == 50
  end

  test "increases num failed accesses on parse fail" do
    page = Page.create :url => "http://tatostrankabynemalaexistovat.com"
    page.download_update
    assert page.num_failed_accesses == 1
  end

  test "sets num failed accesses to 0 on success" do
    page = Page.create :url => "http://tatostrankabynemalaexistovat.com"
    page.download_update
    assert page.num_failed_accesses == 1

    page.url = 'http://fiit.sk'
    page.save
    page.download_update
    assert page.num_failed_accesses == 0
  end
end
