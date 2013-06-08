class ChangeTextTypeInChangedBlocks < ActiveRecord::Migration
  def up
    change_column :changed_blocks, :text, :text
  end

  def down
    change_column :changed_blocks, :text, :string
  end
end
