class Page < ActiveRecord::Base
  has_many :updates
  has_many :planned_updates

  def download_update
    last_update = updates.last

    # Create and download the update
    update = Update.new
    update.page = self
    update.download
    update.save
    update.create_changed_blocks last_update.text unless last_update.nil?

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
