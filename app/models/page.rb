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
        FROM page_rankings ORDER BY page_id, created_at DESC) AS t
      ORDER BY google_rank DESC
      LIMIT #{num_websites})")
  end

  def download_update
    last_update = self.updates.last(:order => 'id DESC')

    # Create and download the update
    begin
      update = Update.new
      update.page = self
      update.download
      update.save
      update.create_changed_blocks last_update.text unless last_update.nil?
      update.save
      UnprocessedCache.create :update => update
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
