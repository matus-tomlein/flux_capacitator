require 'test_helper'

class PlannedUpdateTest < ActiveSupport::TestCase
  test "has longer timespan if previous failed" do
    last_datetime = Time.now
    page = Page.new
    page.save

    update1 = Update.new
    update1.page = page
    update1.created_at = last_datetime
    update1.text_changed = false
    update1.save

    last_datetime = last_datetime.advance :hours => 1
    update2 = Update.new
    update2.page = page
    update2.created_at = last_datetime
    update2.text_changed = false
    update2.save

    last_datetime = last_datetime.advance :hours => 1
    update3 = Update.new
    update3.page = page
    update3.created_at = last_datetime
    update3.text_changed = false
    update3.save

    last_datetime = last_datetime.advance :hours => 1
    update4 = Update.new
    update4.page = page
    update4.created_at = last_datetime
    update4.text_changed = false
    update4.save

    last_datetime = last_datetime.advance :hours => 1
    planned_update = PlannedUpdate.new
    planned_update.page = page
    planned_update.calculate_next_update_date
    assert planned_update.execute_after > last_datetime.advance(:hours => 1)

    update2.text_changed = true
    planned_update.calculate_next_update_date
    assert planned_update.execute_after > last_datetime.advance(:hours => 1)
  end

  test "has shorter timespan if previous succeeded" do
    last_datetime = Time.now
    page = Page.new
    page.save

    update1 = Update.new
    update1.page = page
    update1.created_at = last_datetime
    update1.text_changed = true
    update1.save

    last_datetime = last_datetime.advance :hours => 1
    update2 = Update.new
    update2.page = page
    update2.created_at = last_datetime
    update2.text_changed = true
    update2.save

    last_datetime = last_datetime.advance :hours => 1
    update3 = Update.new
    update3.page = page
    update3.created_at = last_datetime
    update3.text_changed = true
    update3.save

    last_datetime = last_datetime.advance :hours => 1
    update4 = Update.new
    update4.page = page
    update4.created_at = last_datetime
    update4.text_changed = true
    update4.save

    last_datetime = last_datetime.advance :hours => 1
    planned_update = PlannedUpdate.new
    planned_update.page = page
    planned_update.calculate_next_update_date
    assert planned_update.execute_after < last_datetime.advance(:hours => 1)

    update2.text_changed = false
    planned_update.calculate_next_update_date
    assert planned_update.execute_after < last_datetime.advance(:hours => 1)
  end

  test "executes planned update" do
    Page.delete_all
    PlannedUpdate.delete_all
    Update.delete_all
    page = Page.create(:url => "http://sme.sk")
    planned_update = PlannedUpdate.create(:page => page, :execute_after => Time.now.advance(:hours => -1))
    PlannedUpdate.download_planned_updates
    assert PlannedUpdate.first.execute_after > Time.now
    assert Page.first.updates.count == 1
  end

  test "doesnt execute update planned for later" do
    Page.delete_all
    PlannedUpdate.delete_all
    Update.delete_all
    page = Page.create(:url => "http://sme.sk")
    planned_update = PlannedUpdate.create(:page => page, :execute_after => Time.now.advance(:hours => 1))
    PlannedUpdate.download_planned_updates
    assert Page.first.updates.count == 0
  end
end
