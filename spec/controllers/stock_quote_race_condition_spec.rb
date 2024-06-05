require 'rails_helper'
class RecordInvalidTickerTaken < ActiveRecord::RecordInvalid
  def message
    "Validation failed: Ticker has already been taken"
  end
end
RSpec.describe Api::V1::StockQuotesController, type: :controller do
  describe 'POST #create' do
    let(:ticker) { 'AAPL' }
    let(:ticker_params) { { ticker: ticker, price: 10 } }
    let(:company) { FactoryBot.create(:company, ticker: ticker) }

    it 'rescues from the exception and finds the company by ticker' do

      allow_any_instance_of(CompaniesService).to receive(:find_company_by_ticker)
                                                   .with(ticker).and_return(nil, company)
      post :create, params: ticker_params

      expect(response).to have_http_status(:success)
      expect(Company.where(ticker: ticker).count).to eq(1)
      expect(StockQuote.count).to eq(1)
    end
  end
end
