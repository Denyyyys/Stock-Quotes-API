class Company < ApplicationRecord
  validates :ticker, presence: true, length: { minimum: 1, maximum: 5 }
  validates :name, presence: true, length: { minimum: 1 }
  has_many :stock_quotes
end
