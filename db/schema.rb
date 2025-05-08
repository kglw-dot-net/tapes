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

ActiveRecord::Schema[8.0].define(version: 2024_12_27_020419) do
  create_table "continents", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "continent_id"
    t.index ["continent_id"], name: "index_countries_on_continent_id"
  end

  create_table "recording_files", force: :cascade do |t|
    t.string "source"
    t.string "format"
    t.float "length"
    t.string "original"
    t.string "title"
    t.integer "track_no"
    t.boolean "is_private"
    t.string "creator"
    t.string "album"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "recording_id", null: false
    t.string "name"
    t.string "url"
    t.index ["recording_id"], name: "index_recording_files_on_recording_id"
  end

  create_table "recording_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recordings", id: :string, force: :cascade do |t|
    t.text "source"
    t.text "lineage"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "recorded_at"
    t.datetime "uploaded_at"
    t.boolean "is_lma"
    t.string "preferred_format"
    t.boolean "is_active"
    t.integer "show_id"
    t.integer "recording_type_id"
    t.index ["recording_type_id"], name: "index_recordings_on_recording_type_id"
    t.index ["show_id"], name: "index_recordings_on_show_id"
  end

  create_table "shows", force: :cascade do |t|
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "songfishID"
    t.string "songfishPermalink"
    t.string "title"
    t.integer "order"
    t.string "slug"
    t.text "notes"
    t.boolean "is_active"
    t.integer "venue_id"
    t.integer "tour_id"
    t.string "poster_url"
    t.string "color"
    t.index ["tour_id"], name: "index_shows_on_tour_id"
    t.index ["venue_id"], name: "index_shows_on_venue_id"
  end

  create_table "tours", force: :cascade do |t|
    t.string "name"
    t.integer "songfishID"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "venues", force: :cascade do |t|
    t.string "name"
    t.string "city"
    t.string "region"
    t.integer "songfishID"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "country_id"
    t.index ["country_id"], name: "index_venues_on_country_id"
  end

  add_foreign_key "countries", "continents"
  add_foreign_key "recording_files", "recordings"
  add_foreign_key "recordings", "recording_types"
  add_foreign_key "recordings", "shows"
  add_foreign_key "shows", "tours"
  add_foreign_key "shows", "venues"
  add_foreign_key "venues", "countries"
end
