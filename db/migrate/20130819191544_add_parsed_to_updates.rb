class AddParsedToUpdates < ActiveRecord::Migration
  def change
    add_column :updates, :parsed, :boolean, :default => false
  end
end
