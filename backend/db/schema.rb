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

ActiveRecord::Schema[8.1].define(version: 2026_07_03_174805) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_participants_on_name"
  end

  create_table "votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address", null: false
    t.bigint "participant_id", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "wall_id", null: false
    t.index ["created_at"], name: "index_votes_on_created_at"
    t.index ["participant_id", "created_at"], name: "index_votes_on_participant_id_and_created_at"
    t.index ["participant_id"], name: "index_votes_on_participant_id"
    t.index ["wall_id", "created_at"], name: "index_votes_on_wall_id_and_created_at"
    t.index ["wall_id"], name: "index_votes_on_wall_id"
  end

  create_table "wall_participants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "participant_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "wall_id", null: false
    t.index ["participant_id"], name: "index_wall_participants_on_participant_id"
    t.index ["wall_id", "participant_id"], name: "idx_wall_participant_unique", unique: true
    t.index ["wall_id"], name: "index_wall_participants_on_wall_id"
  end

  create_table "walls", force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at", null: false
    t.string "name", null: false
    t.datetime "starts_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active"], name: "index_walls_on_active"
  end

  add_foreign_key "votes", "participants"
  add_foreign_key "votes", "walls"
  add_foreign_key "wall_participants", "participants"
  add_foreign_key "wall_participants", "walls"
end
