class AddLinksProcessingIdToUpdates < ActiveRecord::Migration
  def change
    add_column :updates, :links_processing_id, :integer
  end
end
