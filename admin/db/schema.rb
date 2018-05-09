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

ActiveRecord::Schema.define(version: 20180507180914) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "downloads", force: :cascade do |t|
    t.string   "key"
    t.integer  "year"
    t.integer  "day"
    t.integer  "tile"
    t.string   "typ"
    t.integer  "count"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_downloads_on_key", unique: true, using: :btree
    t.index ["user_id"], name: "index_downloads_on_user_id", using: :btree
  end

  create_table "records", force: :cascade do |t|
    t.integer  "year"
    t.integer  "day"
    t.integer  "tile"
    t.string   "suffix"
    t.integer  "used"
    t.datetime "last_used"
    t.datetime "created"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_records_on_user_id", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.integer  "map_height"
    t.string   "map_center"
    t.integer  "map_zoom"
    t.boolean  "show_grid"
    t.boolean  "show_selection"
    t.float    "tile_opacity"
    t.string   "selection"
    t.integer  "tile_size"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.boolean  "is_default"
    t.string   "name"
    t.string   "map_option"
    t.string   "image_option"
    t.index ["user_id"], name: "index_settings_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "role"
    t.string   "auth_token"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "country"
    t.string   "state"
    t.string   "city"
    t.string   "affiliation"
    t.string   "employer"
    t.string   "title"
    t.string   "purpose"
    t.string   "hear_from"
    t.string   "status"
    t.string   "verification_key"
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["verification_key"], name: "index_users_on_verification_key", using: :btree
  end

  add_foreign_key "downloads", "users"
  add_foreign_key "records", "users"
  add_foreign_key "settings", "users"
end
