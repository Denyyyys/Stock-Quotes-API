class StockQuote < ApplicationRecord
  belongs_to :company
  validates :price, presence: true, numericality: { greater_than: 0 }
  validate :valid_created_at_timestamp, if: -> { created_at.present? }

  private
  def valid_created_at_timestamp
    unless created_at.is_a?(Time) || created_at.is_a?(ActiveSupport::TimeWithZone)
      errors.add(:created_at, "must be a valid timestamp")
    end
  end
end
