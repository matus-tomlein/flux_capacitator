class CreatePlannedUpdates < ActiveRecord::Migration
  def change
    create_table :planned_updates do |t|
      t.datetime :execute_after
      t.references :page

      t.timestamps
    end
    add_index :planned_updates, :page_id
  end
end
