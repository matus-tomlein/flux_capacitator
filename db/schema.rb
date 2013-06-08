# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130608173230) do

  create_table "changed_blocks", :force => true do |t|
    t.integer  "update_id"
    t.text     "text"
    t.integer  "change_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "changed_blocks", ["update_id"], :name => "index_changed_blocks_on_update_id"

  create_table "pages", :force => true do |t|
    t.text     "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "stripped_url"
  end

  create_table "planned_updates", :force => true do |t|
    t.datetime "execute_after"
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "planned_updates", ["page_id"], :name => "index_planned_updates_on_page_id"

  create_table "unprocessed_caches", :force => true do |t|
    t.integer  "update_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unprocessed_caches", ["update_id"], :name => "index_unprocessed_caches_on_update_id"

  create_table "updates", :force => true do |t|
    t.integer  "page_id"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cache_folder_name"
    t.text     "text"
    t.boolean  "text_changed"
  end

  add_index "updates", ["page_id"], :name => "index_updates_on_page_id"

end
