# frozen_string_literal: true

# Migration to enforce non-nullability and positivity of the price column in the stock_quotes table.
class PriceColumnOfStockQuoteCannotBeNullOrNegative < ActiveRecord::Migration[7.1]
  def change
    change_column :stock_quotes, :price, :decimal, precision: 10, scale: 2, null: false
  end
end
