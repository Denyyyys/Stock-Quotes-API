# frozen_string_literal: true

class Company < ApplicationRecord
  validates :ticker, presence: true, length: { minimum: 1, maximum: 5 }, uniqueness: true
  validates :name, presence: true
  has_many :stock_quotes
end
