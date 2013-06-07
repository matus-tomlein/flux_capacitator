class AddTextChangedToUpdates < ActiveRecord::Migration
  def change
    add_column :updates, :text_changed, :boolean
  end
end
