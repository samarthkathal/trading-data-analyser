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

ActiveRecord::Schema[7.0].define(version: 2023_07_24_170632) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "historical_positions", id: false, force: :cascade do |t|
    t.bigint "unique_id", null: false
    t.string "trader_id", null: false
    t.string "instrument_id", null: false
    t.integer "leverage", null: false
    t.decimal "margin", null: false
    t.decimal "pnl", null: false
    t.string "margin_mode", null: false
    t.decimal "open_avg_price", null: false
    t.decimal "close_avg_price", null: false
    t.decimal "side", null: false
    t.datetime "open_time", null: false
    t.datetime "close_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unique_id"], name: "index_historical_positions_on_unique_id", unique: true
  end

  create_table "instruments", id: false, force: :cascade do |t|
    t.string "instrument_id", null: false
    t.string "name", null: false
    t.decimal "contract_multiplier"
    t.string "contract_type"
    t.decimal "contract_value"
    t.string "contract_currency"
    t.string "settle_currency"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instrument_id"], name: "index_instruments_on_instrument_id", unique: true
  end

  create_table "trader_instruments", force: :cascade do |t|
    t.string "trader_id", null: false
    t.string "instrument_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "traders", id: false, force: :cascade do |t|
    t.string "unique_name", null: false
    t.string "name", null: false
    t.decimal "aum"
    t.decimal "pnl"
    t.decimal "win_ratio"
    t.decimal "yield_ratio"
    t.datetime "last_scrapped_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["unique_name"], name: "index_traders_on_unique_name", unique: true
  end

  add_foreign_key "historical_positions", "instruments", primary_key: "instrument_id"
  add_foreign_key "historical_positions", "traders", primary_key: "unique_name"
  add_foreign_key "trader_instruments", "instruments", primary_key: "instrument_id"
  add_foreign_key "trader_instruments", "traders", primary_key: "unique_name"
end
