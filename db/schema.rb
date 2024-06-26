# frozen_string_literal: true

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

ActiveRecord::Schema[7.1].define(version: 20_240_510_124_146) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'companies', force: :cascade do |t|
    t.string 'name'
    t.string 'ticker', null: false
    t.string 'origin_country'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['ticker'], name: 'index_companies_on_ticker', unique: true
  end

  create_table 'stock_quotes', force: :cascade do |t|
    t.decimal 'price', precision: 10, scale: 2, null: false
    t.bigint 'company_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['company_id'], name: 'index_stock_quotes_on_company_id'
  end

  add_foreign_key 'stock_quotes', 'companies'
end
