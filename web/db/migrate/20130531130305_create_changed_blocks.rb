class CreateChangedBlocks < ActiveRecord::Migration
  def change
    create_table :changed_blocks do |t|
      t.references :update
      t.string :text
      t.integer :change_type

      t.timestamps
    end
    add_index :changed_blocks, :update_id
  end
end
