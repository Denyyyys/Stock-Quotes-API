class StockQuoteSerializer < ActiveModel::Serializer
  attributes :id, :price, :company_ticker, :created_at
  def company_ticker
    company = Company.find(self.object.company_id)
    if company
      company.ticker
    end
  end
end
