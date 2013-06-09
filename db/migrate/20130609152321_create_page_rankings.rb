class CreatePageRankings < ActiveRecord::Migration
  def change
    create_table :page_rankings do |t|
      t.integer :google_backlinks
      t.integer :bing_backlinks
      t.integer :yahoo_backlinks
      t.integer :google_rank
      t.integer :alexa_global_rank
      t.references :page

      t.timestamps
    end
    add_index :page_rankings, :page_id
  end
end
