class CreateUpdates < ActiveRecord::Migration
  def change
    create_table :updates do |t|
      t.references :page
      t.text :content

      t.timestamps
    end
    add_index :updates, :page_id
  end
end
