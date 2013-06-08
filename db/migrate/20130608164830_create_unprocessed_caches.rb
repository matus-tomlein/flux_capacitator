class CreateUnprocessedCaches < ActiveRecord::Migration
  def change
    create_table :unprocessed_caches do |t|
      t.references :update

      t.timestamps
    end
    add_index :unprocessed_caches, :update_id
  end
end
