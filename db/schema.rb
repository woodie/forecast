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

ActiveRecord::Schema[8.0].define(version: 2024_12_28_194800) do
  create_table "addresses", force: :cascade do |t|
    t.string "query"
    t.integer "place_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["place_id"], name: "index_addresses_on_place_id"
  end

  create_table "places", force: :cascade do |t|
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "country_code"
    t.string "postal_code"
    t.float "lat"
    t.float "lon"
    t.json "current_weather"
    t.json "weather_forecast"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "timezone"
    t.index ["postal_code", "country_code"], name: "index_places_on_postal_code_and_country_code"
  end

  add_foreign_key "addresses", "places"
end
