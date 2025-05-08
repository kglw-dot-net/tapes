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

ActiveRecord::Schema[8.0].define(version: 2025_01_18_183522) do
  create_table "albums", force: :cascade do |t|
    t.string "title"
    t.integer "year"
    t.string "cover_art_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
    t.string "slug"
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
    t.integer "taper_id"
    t.index ["recording_type_id"], name: "index_recordings_on_recording_type_id"
    t.index ["show_id"], name: "index_recordings_on_show_id"
    t.index ["taper_id"], name: "index_recordings_on_taper_id"
  end

  create_table "set_songs", force: :cascade do |t|
    t.integer "songfishID"
    t.integer "song_id", null: false
    t.integer "position"
    t.float "duration"
    t.text "footnote"
    t.boolean "is_jamchart"
    t.text "jamchart_notes"
    t.boolean "is_reprise"
    t.boolean "is_verified"
    t.boolean "is_recommended"
    t.boolean "is_jam"
    t.integer "transition_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "setlist_id", null: false
    t.index ["setlist_id"], name: "index_set_songs_on_setlist_id"
    t.index ["song_id"], name: "index_set_songs_on_song_id"
    t.index ["transition_id"], name: "index_set_songs_on_transition_id"
  end

  create_table "set_types", force: :cascade do |t|
    t.integer "songfishID"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "setlists", force: :cascade do |t|
    t.integer "show_id", null: false
    t.integer "setnumber"
    t.integer "set_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["set_type_id"], name: "index_setlists_on_set_type_id"
    t.index ["show_id"], name: "index_setlists_on_show_id"
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

  create_table "songs", force: :cascade do |t|
    t.integer "songfishID"
    t.string "name"
    t.string "slug"
    t.boolean "is_original"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "album_id"
    t.index ["album_id"], name: "index_songs_on_album_id"
  end

  create_table "tapers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tours", force: :cascade do |t|
    t.string "name"
    t.integer "songfishID"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transitions", force: :cascade do |t|
    t.integer "songfishID"
    t.string "separator"
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
  add_foreign_key "recordings", "tapers"
  add_foreign_key "set_songs", "setlists"
  add_foreign_key "set_songs", "songs"
  add_foreign_key "set_songs", "transitions"
  add_foreign_key "setlists", "set_types"
  add_foreign_key "setlists", "shows"
  add_foreign_key "shows", "tours"
  add_foreign_key "shows", "venues"
  add_foreign_key "songs", "albums"
  add_foreign_key "venues", "countries"
end
