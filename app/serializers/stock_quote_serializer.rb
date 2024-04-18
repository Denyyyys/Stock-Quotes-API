class StockQuoteSerializer < ActiveModel::Serializer
  attributes :id, :price, :ticker, :created_at
  def ticker
    company = Company.find(self.object.company_id)
    if company
      company.ticker
    end
  end

  def price
    object.price.to_f # Ensure price is serialized as float
  end
end
