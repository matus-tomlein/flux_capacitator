class PageRanking < ActiveRecord::Base
  belongs_to :page

  def self.update_rankings
    pages = Page.all(:order => 'page_rank_updated_at NULLS FIRST, random()', :limit => 3)
    pages.each do |page|
      ranking = PageRanking.new
      ranking.page = page
      if ranking.get_ranking
        ranking.save
        page.page_rank_updated_at = ranking.created_at
        page.save
      end
    end
  end

  def get_ranking
    begin
      backlinks = PageRankr.backlinks(self.page.stripped_url, :google, :bing, :yahoo)
      return false if backlinks.nil?
      self.google_backlinks = backlinks[:google]
      self.bing_backlinks = backlinks[:bing]
      self.yahoo_backlinks = backlinks[:yahoo]

      ranks = PageRankr.ranks(self.page.stripped_url, :alexa_global, :google)
      return false if ranks.nil?
      self.google_rank = ranks[:google]
      self.alexa_global_rank = ranks[:alexa_global]
    rescue => ex
      $stderr.puts ex.message
      return false
    end
    true
  end
end
