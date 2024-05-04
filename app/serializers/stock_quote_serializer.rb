# frozen_string_literal: true

class StockQuoteSerializer < ActiveModel::Serializer
  attributes :id, :price, :ticker, :created_at
  def ticker
    company = Company.find(object.company_id)
    return unless company

    company.ticker
  end

  def price
    object.price.to_f # Ensure price is serialized as float
  end
end
