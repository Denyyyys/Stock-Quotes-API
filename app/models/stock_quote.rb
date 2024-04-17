class StockQuote < ApplicationRecord
  belongs_to :company
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
