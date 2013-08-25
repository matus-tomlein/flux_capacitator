class AddImportanceToPages < ActiveRecord::Migration
  def change
    add_column :pages, :priority, :integer, :default => 0
  end
end
