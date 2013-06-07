class AddTextToUpdates < ActiveRecord::Migration
  def change
    add_column :updates, :text, :string
  end
end
