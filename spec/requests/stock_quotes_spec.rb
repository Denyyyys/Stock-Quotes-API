require 'rails_helper'

RSpec.describe "StockQuotes", type: :request do
  let!(:companies) do
    [
      FactoryBot.create(:company, name: "Microsoft", ticker: "MSFT", origin_country: "USA"),
      FactoryBot.create(:company, name: "Apple", ticker: "AAPL", origin_country: "USA")
    ]
  end
  let!(:apple_stock_quotes) do
    [
      FactoryBot.create(:stock_quote, price: 102, company: companies[1]),
      FactoryBot.create(:stock_quote, price: 122, company: companies[1]),
      FactoryBot.create(:stock_quote, price: 132, company: companies[1]),
    ]
  end
  let!(:microsoft_stock_quotes) do
    [
      FactoryBot.create(:stock_quote, price: 102, company: companies[0]),
    ]
  end
  describe "GET api/v1/stock_quotes/ticker/:ticker" do
    it "get all stock quotes" do
      get "/api/v1/stock_quotes/ticker/AAPL"
      expect(response).to be_present
      expect(response).to have_http_status(:success)
      expect(response_body).to be_an_instance_of(Array)
      expect(response_body.length).to eq(3)
    end

    it "get stock quotes of company, which does not exist" do
      get "/api/v1/stock_quotes/ticker/not_exist"
      expect(response).to have_http_status(:not_found)
      expect(response_body).to eq({"error"=>"Company with ticker 'not_exist' not found"})
    end
  end

  describe "DELETE api/v1/stock_quotes/:id" do
    it "successfully delete stock quote by id" do
      expect {
        delete "/api/v1/stock_quotes/#{apple_stock_quotes[0].id}"
      }.to change(StockQuote, :count).by(-1)
      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end

    it "stock quote with provided negative integer error" do
      id = 0
      expect {
        delete "/api/v1/stock_quotes/#{id}"
      }.to change(StockQuote, :count).by(0)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body).to eq({"error"=> "Id of stock quote should be positive integer! Provided: #{id}"})
    end

    it "provided id is not integer error" do
      id = "not_integer"
      expect {
        delete "/api/v1/stock_quotes/#{id}"
      }.to change(StockQuote, :count).by(0)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body).to eq({"error"=> "Id of stock quote should be positive integer! Provided: #{id}"})
    end
  end

  describe "DELETE api/v1/stock_quotes/ticker/:ticker" do
    it "provided correct ticker" do
      ticker = "MSFT"
      expect {
        delete "/api/v1/stock_quotes/ticker/#{ticker}"
      }.to change(StockQuote, :count).by(-1)

      expect {
        delete "/api/v1/stock_quotes/ticker/#{ticker}"
      }.to change(Company, :count).by(0)
      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end

    it "provided incorrect ticker" do
      ticker = "not_ticker"
      expect {
        delete "/api/v1/stock_quotes/ticker/#{ticker}"
      }.to change(StockQuote, :count).by(0)
      expect {
        delete "/api/v1/stock_quotes/ticker/#{ticker}"
      }.to change(Company, :count).by(0)

      expect(response).to have_http_status(:not_found)
      expect(response_body).to eq({"error"=> "Company with ticker '#{ticker}' not found"})
    end
  end


end
