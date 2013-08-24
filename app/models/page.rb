class Page < ActiveRecord::Base
  has_many :updates
  has_many :planned_updates

  def self.update_tracked_websites
    Page.retrack_websites_by_rank 2000
  end

  def self.retrack_websites_by_rank(num_websites)
    Page.update_all :track => false
    ActiveRecord::Base.connection.execute("UPDATE pages SET track = TRUE
    WHERE id IN (SELECT page_id FROM
        (SELECT DISTINCT ON (page_id) page_id, google_rank
        FROM page_rankings
        JOIN pages on page_rankings.page_id = pages.id AND pages.num_failed_accesses < 2
        ORDER BY page_id, page_rankings.created_at DESC) AS t
      ORDER BY google_rank DESC
      LIMIT #{num_websites})")

    pages = Page.where("track = TRUE AND id NOT IN (SELECT page_id FROM planned_updates)")
    pages.each do |page|
      page.plan_next_update
    end

    ActiveRecord::Base.connection.execute("DELETE FROM planned_updates WHERE page_id NOT IN (SELECT id FROM pages WHERE track = TRUE)")
  end

  def download_update
    last_update = self.updates.last(:order => 'id DESC')

    # Create and download the update
    begin
      update = Update.new
      update.page = self
      success = update.download_and_parse
      update.save

      if !success
        self.num_failed_accesses += 1
        self.save
      elsif self.num_failed_accesses > 0
        self.num_failed_accesses = 0
        self.save
      end
    rescue => ex
      $stderr.puts ex.message
    end

    plan_next_update
  end

  def plan_next_update
    planned_update = PlannedUpdate.new
    planned_update.page = self
    planned_update.calculate_next_update_date
    planned_update.save
  end

  def self.strip_url_and_find(value)
    find_by_stripped_url(Page.get_stripped_url(value))
  end

  def url=(value)
    write_attribute(:url, value)
    self.stripped_url = Page.get_stripped_url value
  end

  def self.get_stripped_url(value)
    stripped_url = value.chomp('/').downcase
    stripped_url[0..6] = '' if stripped_url.start_with? "http://"
    stripped_url[0..3] = '' if stripped_url.start_with? "www."
    stripped_url[0..3] = '' if stripped_url.start_with? "www."
    stripped_url
  end
end
