# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_04_20_083549) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "click_events", force: :cascade do |t|
    t.bigint "short_url_id", null: false
    t.datetime "clicked_at", null: false
    t.string "ip_address", limit: 45
    t.string "country", limit: 100
    t.string "region", limit: 100
    t.string "city", limit: 100
    t.text "user_agent"
    t.text "referrer"
    t.datetime "geo_resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["clicked_at"], name: "index_click_events_on_clicked_at"
    t.index ["id"], name: "idx_click_events_geo_pending", where: "(geo_resolved_at IS NULL)"
    t.index ["short_url_id", "clicked_at"], name: "index_click_events_on_short_url_id_and_clicked_at"
    t.index ["short_url_id"], name: "index_click_events_on_short_url_id"
  end

  create_table "short_urls", force: :cascade do |t|
    t.string "short_code", limit: 15, null: false
    t.text "target_url", null: false
    t.string "title", limit: 500
    t.datetime "title_fetched_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["short_code"], name: "index_short_urls_on_short_code", unique: true
  end

  add_foreign_key "click_events", "short_urls"
end
