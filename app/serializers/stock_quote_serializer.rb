class StockQuoteSerializer < ActiveModel::Serializer
  attributes :id, :price, :company_ticker, :created_at
  def company_ticker
    company = Company.find(self.object.company_id)
    if company
      "ticker: #{company.ticker}"
    end
  end

  def price
    object.price.to_f # Ensure price is serialized as float
  end
end
