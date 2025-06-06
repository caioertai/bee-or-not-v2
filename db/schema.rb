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

ActiveRecord::Schema[8.0].define(version: 2025_06_06_065632) do
  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "guesses", force: :cascade do |t|
    t.integer "round_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "real"
    t.index ["round_id", "created_at"], name: "index_guesses_on_round_id_and_created_at"
    t.index ["round_id"], name: "index_guesses_on_round_id"
  end

  create_table "headlines", force: :cascade do |t|
    t.string "content", null: false
    t.boolean "real", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "source_id", null: false
    t.string "source_url"
    t.index ["real"], name: "index_headlines_on_real"
    t.index ["source_id"], name: "index_headlines_on_source_id"
  end

  create_table "rounds", force: :cascade do |t|
    t.integer "game_id", null: false
    t.integer "headline_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "created_at"], name: "index_rounds_on_game_id_and_created_at"
    t.index ["game_id"], name: "index_rounds_on_game_id"
    t.index ["headline_id"], name: "index_rounds_on_headline_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string "base_url"
    t.string "slug"
    t.string "name"
    t.boolean "real"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "guesses", "rounds"
  add_foreign_key "headlines", "sources"
  add_foreign_key "rounds", "games"
  add_foreign_key "rounds", "headlines"
end
