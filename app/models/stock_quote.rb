# frozen_string_literal: true

class StockQuote < ApplicationRecord
  belongs_to :company
  validates :price, presence: true, numericality: { greater_than: 0 }
end
