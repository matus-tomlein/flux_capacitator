class PlannedUpdate < ActiveRecord::Base
  belongs_to :page

  @@default_timespan = 1
  @@max_timespan = 168
  @@min_timespan = 0.5

  ## Executed periodically, downloads the first planned update on the stack
  def self.download_planned_updates
    planned_update = PlannedUpdate.where('execute_after < ?', Time.now).first(:order => 'execute_after')
    return if planned_update.nil?
    page = planned_update.page
    planned_update.delete
    page.download_update
  end

  def calculate_next_update_date
    updates = page.updates.order('id DESC').limit(4).reverse
    previous_update = nil
    hour_differences = []
    num_changed = 0
    num_unchanged = 0
    updates.each do |update|
      if previous_update.nil?
        previous_update = update
        next
      end
      hour_differences << time_diff_in_hours(update.created_at, previous_update.created_at)
      num_unchanged += 1 unless update.text_changed
      num_changed += 1 if update.text_changed

      previous_update = update
    end

    timespan = @@default_timespan
    if hour_differences.count < 3
      timespan = @@default_timespan
    elsif num_changed == 3
      timespan = 0.9 * hour_differences.last
    elsif num_unchanged == 3
      timespan = hour_differences.inject{|sum,x| sum + x }
    elsif num_changed > num_unchanged
      timespan = hour_differences.max
    elsif num_unchanged > num_changed
      timespan = hour_differences.inject{|sum,x| sum + x }
    end

    timespan = [[timespan, @@max_timespan].min, @@min_timespan].max
    self.execute_after = Time.now.advance(:hours => timespan) if previous_update.nil?
    self.execute_after = previous_update.created_at.advance(:hours => timespan) unless previous_update.nil?
  end

  def time_diff_in_hours(time1, time2)
    diff_seconds = time1 - time2
    return diff_seconds.to_f / 3600
  end
end