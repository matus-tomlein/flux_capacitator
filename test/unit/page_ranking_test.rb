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
end
