class AddCacheFolderNameToUpdates < ActiveRecord::Migration
  def change
    add_column :updates, :cache_folder_name, :string
  end
end
