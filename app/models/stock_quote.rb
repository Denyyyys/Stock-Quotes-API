# frozen_string_literal: true

# Represents a stock quote entity in the database
class StockQuote < ApplicationRecord
  belongs_to :company
  validates :price, presence: true, numericality: { greater_than: 0 }
end
