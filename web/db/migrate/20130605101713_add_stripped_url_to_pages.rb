class AddStrippedUrlToPages < ActiveRecord::Migration
  def change
    add_column :pages, :stripped_url, :text
  end
end
