class ChangeTextTypeInUpdates < ActiveRecord::Migration
  def up
    change_column :updates, :text, :text
  end

  def down
    change_column :updates, :text, :string
  end
end
