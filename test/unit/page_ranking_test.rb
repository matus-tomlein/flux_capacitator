require 'test_helper'

class PageRankingTest < ActiveSupport::TestCase
  test "gets rankings" do
    ranking = PageRanking.new
    ranking.page = Page.create :url => 'sme.sk'
    assert ranking.get_ranking
    assert ranking.bing_backlinks > 0
    assert ranking.google_rank > 0
    assert ranking.alexa_global_rank > 0
  end

  test "smts" do
    Page.create :url => "1"
    Page.create :url => "2", :page_rank_updated_at => Time.now
    Page.create :url => "3"
    page = Page.all(:order => 'page_rank_updated_at NULLS FIRST')
    puts page.first.url
    assert page.first.url == "1"
    assert page.last.url == "2"
  end
end
