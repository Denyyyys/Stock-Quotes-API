# frozen_string_literal: true

# Migration to create the stock quotes table in the database
class CreateStockQuotes < ActiveRecord::Migration[7.1]
  def change
    create_table :stock_quotes do |t|
      t.decimal :price
      t.belongs_to :company, null: false, foreign_key: true
      t.timestamps
    end
  end
end
