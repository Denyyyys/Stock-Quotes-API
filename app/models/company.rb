# frozen_string_literal: true

# Represents a company entity in the database
class Company < ApplicationRecord
  validates :ticker, presence: true, length: { minimum: 1, maximum: 5 }, uniqueness: true
  has_many :stock_quotes
end
