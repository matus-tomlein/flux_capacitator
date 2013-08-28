class CreateLinksToDownloads < ActiveRecord::Migration
  def change
    create_table :links_to_downloads do |t|
      t.text :url
      t.integer :rank
      t.references :update

      t.timestamps
    end
    add_index :links_to_downloads, :update_id
  end
end
