# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_09_24_112311) do

  create_table "customer_points_entries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "transaction_id"
    t.decimal "points", precision: 20, null: false
    t.bigint "reward_program_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["customer_id"], name: "index_customer_points_entries_on_customer_id"
    t.index ["transaction_id"], name: "index_customer_points_entries_on_transaction_id"
  end

  create_table "customer_rewards", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "reward_id", null: false
    t.bigint "reward_program_id"
    t.decimal "quantity", precision: 10
    t.integer "status", limit: 1
    t.datetime "expires_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "gid", limit: 40, null: false
    t.index ["customer_id"], name: "index_customer_rewards_on_customer_id"
    t.index ["gid"], name: "index_customer_rewards_on_gid"
  end

  create_table "customers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "gid", limit: 40, null: false
    t.string "name"
    t.string "email"
    t.string "external_id"
    t.date "birthday"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "points", precision: 20, default: "0"
    t.index ["external_id"], name: "index_customers_on_external_id", unique: true
    t.index ["gid"], name: "index_customers_on_gid"
  end

  create_table "rewards", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "gid", limit: 40, null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["gid"], name: "index_rewards_on_gid"
  end

  create_table "transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "gid", limit: 40, null: false
    t.string "external_id"
    t.integer "region_type", limit: 1, default: 1
    t.decimal "amount", precision: 20, scale: 5, null: false
    t.datetime "transaction_date"
    t.bigint "customer_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["external_id"], name: "index_transactions_on_external_id", unique: true
    t.index ["gid"], name: "index_transactions_on_gid"
  end

end
