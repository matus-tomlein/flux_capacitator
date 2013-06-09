class AddPageRankUpdatedAtToPages < ActiveRecord::Migration
  def change
    add_column :pages, :page_rank_updated_at, :datetime
    add_column :pages, :track, :boolean, :default => false
  end
end
