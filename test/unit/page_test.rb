require 'test_helper'

class PageTest < ActiveSupport::TestCase
  test "choosing tracked pages" do
    100.times do |i|
      page = Page.create :url => "http://#{i}.com"
      (Random.rand(3) + 1).times do
        PageRanking.create :page => page, :google_rank => Random.rand(12)
      end
    end
    Page.retrack_websites_by_rank 50
    assert Page.find_all_by_track(true).count == 50
  end
end
