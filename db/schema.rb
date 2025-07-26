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

ActiveRecord::Schema[7.2].define(version: 2025_07_13_025931) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.index ["code"], name: "index_companies_on_code", unique: true
  end

  create_table "credentials_twitters", force: :cascade do |t|
    t.text "api_key"
    t.text "api_key_secret"
    t.text "access_token"
    t.text "access_token_secret"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_credentials_twitters_on_company_id", unique: true
  end

  create_table "jwt_denylist", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylist_on_jti"
  end

  create_table "posts", force: :cascade do |t|
    t.string "title", limit: 255, null: false
    t.string "description", limit: 500
    t.string "image_url"
    t.string "tags", limit: 255
    t.datetime "programming_date_to_post", null: false
    t.boolean "is_published", default: false, null: false
    t.bigint "team_member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "strategy_id"
    t.string "category"
    t.string "emoji"
    t.integer "status"
    t.index ["strategy_id"], name: "index_posts_on_strategy_id"
    t.index ["team_member_id"], name: "index_posts_on_team_member_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "strategies", force: :cascade do |t|
    t.datetime "from_schedule"
    t.datetime "to_schedule"
    t.string "description"
    t.integer "status"
    t.json "success_response"
    t.json "error_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.bigint "team_member_id", null: false
    t.index ["company_id"], name: "index_strategies_on_company_id"
    t.index ["team_member_id"], name: "index_strategies_on_team_member_id"
  end

  create_table "team_members", force: :cascade do |t|
    t.integer "user_id"
    t.bigint "team_id", null: false
    t.integer "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_members_on_team_id"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
    t.index ["code"], name: "index_teams_on_code", unique: true
    t.index ["company_id"], name: "index_teams_on_company_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "title", null: false
    t.string "description", limit: 500
    t.string "image_url"
    t.string "tags", limit: 255
    t.string "category", null: false
    t.string "emoji", null: false
    t.bigint "company_id", null: false
    t.bigint "team_id"
    t.boolean "is_default", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_templates_on_category"
    t.index ["company_id"], name: "index_templates_on_company_id"
    t.index ["is_default"], name: "index_templates_on_is_default"
    t.index ["team_id"], name: "index_templates_on_team_id"
    t.index ["title", "company_id"], name: "index_templates_on_title_and_company_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "role"
    t.boolean "did_tutorial", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "credentials_twitters", "companies"
  add_foreign_key "posts", "strategies"
  add_foreign_key "posts", "team_members"
  add_foreign_key "strategies", "companies"
  add_foreign_key "strategies", "team_members"
  add_foreign_key "team_members", "teams"
  add_foreign_key "teams", "companies"
  add_foreign_key "templates", "companies"
  add_foreign_key "templates", "teams"
end
