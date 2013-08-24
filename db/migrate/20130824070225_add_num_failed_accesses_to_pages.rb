class AddNumFailedAccessesToPages < ActiveRecord::Migration
  def change
    add_column :pages, :num_failed_accesses, :integer, :default => 0
  end
end
