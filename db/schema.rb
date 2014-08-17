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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140413041236) do

  create_table "activities", force: true do |t|
    t.integer  "user_id"
    t.string   "activity_type",    limit: 32
    t.string   "activity_message"
    t.datetime "created_at"
  end

  create_table "assets", force: true do |t|
    t.string   "name"
    t.string   "slug"
    t.string   "file_type"
    t.string   "location"
    t.integer  "owner"
    t.integer  "parent"
    t.string   "visibility"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "block_ips", force: true do |t|
    t.string "ip", limit: 15
  end

  create_table "categories", force: true do |t|
    t.string  "name"
    t.string  "slug"
    t.integer "parent_category"
  end

  create_table "ckeditor_assets", force: true do |t|
    t.string   "data_file_name",               null: false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.integer  "assetable_id"
    t.string   "assetable_type",    limit: 30
    t.string   "type",              limit: 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], name: "idx_ckeditor_assetable", using: :btree
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], name: "idx_ckeditor_assetable_type", using: :btree

  create_table "meta", force: true do |t|
    t.string  "page_title"
    t.string  "page_description"
    t.string  "page_keywords"
    t.boolean "no_index"
    t.boolean "no_follow"
  end

  create_table "pages", force: true do |t|
    t.integer  "created_by"
    t.string   "content_title"
    t.text     "content"
    t.string   "url_slug"
    t.string   "status"
    t.integer  "template_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["created_by", "category_id"], name: "index_pages_on_created_by_and_category_id_and_meta_id", using: :btree

  create_table "roles", force: true do |t|
    t.string "name",        limit: 64
    t.string "permissions", limit: 512
    t.string "status",      limit: 10
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: true do |t|
    t.string "setting_name",  limit: 64
    t.text   "setting_value", limit: 2147483647
  end

  create_table "templates", force: true do |t|
    t.string   "name"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "traffics", force: true do |t|
    t.string   "ip",         limit: 20
    t.string   "url"
    t.string   "browser",    limit: 128
    t.string   "status",     limit: 3
    t.datetime "created_at"
  end

  create_table "user_requests", force: true do |t|
    t.string   "email"
    t.string   "role"
    t.string   "token"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "username"
    t.string   "fullname"
    t.integer  "role_id"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "session_id",           limit: 64
    t.string   "authentication_token", limit: 64
    t.string   "reset_password_token"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "widgets", force: true do |t|
    t.string   "title"
    t.string   "alias"
    t.text     "content"
    t.integer  "created_by"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
