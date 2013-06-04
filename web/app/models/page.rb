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
end
