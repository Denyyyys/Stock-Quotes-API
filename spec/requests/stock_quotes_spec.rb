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
  describe "GET /api/v1/stock_quotes/ticker/:ticker" do
    it "get all stock quotes" do
      get "/api/v1/stock_quotes/ticker/AAPL"
      expect(response).to be_present
      expect(response).to have_http_status(:success)
      expect(response_body).to be_an_instance_of(Array)
      expect(response_body.length).to eq(3)
    end

    it "get stock quotes of company, which does not exist" do
      wrong_ticker = "not_exists"
      get "/api/v1/stock_quotes/ticker/#{wrong_ticker}"
      expect(response).to have_http_status(:not_found)
      expect(response_body).to eq({"error"=>"Company with ticker #{wrong_ticker} not found"})
    end
  end

  describe "DELETE /api/v1/stock_quotes/:id" do
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

  describe "DELETE /api/v1/stock_quotes/ticker/:ticker" do
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
      expect(response_body).to eq({"error"=> "Company with ticker #{ticker} not found"})
    end
  end

  describe "POST /api/v1/stock_quotes" do
    it "Add stock quote with correct data without timestamp" do
      expect {
        post "/api/v1/stock_quotes", params: {ticker: "MSFT", price: 102.92}
      }.to change(StockQuote, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(response_body).to be_present

      expect(response_body["id"]).to be_present
      expect(response_body["price"]).to eq(102.92)
      expect(response_body["ticker"]).to eq("MSFT")
      expect(response_body["created_at"]).to be_present
    end

    it "Add stock quote with correct data with timestamp" do
      expect {
        post "/api/v1/stock_quotes", params: {ticker: "MSFT", price: 102.92, created_at: "1.02.2023 10:20"}
      }.to change(StockQuote, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(response_body).to be_present

      expect(response_body["id"]).to be_present
      expect(response_body["price"]).to eq(102.92)
      expect(response_body["ticker"]).to eq("MSFT")
      expect(response_body["created_at"]).to eq("2023-02-01T10:20:00.000Z")
    end

    it "Add stock quote with incorrect timestamp error" do
      timestamp = "not_timestamp"
      expect {
        post "/api/v1/stock_quotes", params: {ticker: "MSFT", price: 102.92, created_at: timestamp}
      }.to change(StockQuote, :count).by(0)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body).to be_present

      expect(response_body).to eq({"error" => "Provided timestamp is invalid! Provided: #{timestamp}"})
    end

    it "Add stock quote with incorrect ticker error" do
      ticker = "not_valid_ticker"
      expect {
        post "/api/v1/stock_quotes", params: {ticker: ticker, price: 102.92}
      }.to change(StockQuote, :count).by(0)

      expect(response).to have_http_status(:not_found)
      expect(response_body).to be_present
      expect(response_body).to eq({"error" => "Company with ticker: '#{ticker}' could not be found!"})
    end

    it "Add stock quote without ticker error" do
      expect {
        post "/api/v1/stock_quotes", params: { price: 102.92}
      }.to change(StockQuote, :count).by(0)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body).to be_present
      expect(response_body).to eq({"error" => "Ticker can't be blank!"})
    end

    it "Add stock quote without price error" do
      expect {
        post "/api/v1/stock_quotes", params: {ticker: "MSFT"}
      }.to change(StockQuote, :count).by(0)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body).to be_present
      expect(response_body).to eq({"error" => "Price can't be blank, Price is not a number"})
    end

    it "Add stock quote with negative price error" do
      price = -123.3
      expect {
        post "/api/v1/stock_quotes", params: {ticker: "MSFT", price: price}
      }.to change(StockQuote, :count).by(0)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body).to be_present
      expect(response_body).to eq({"error" => "Price must be greater than 0"})
    end

    it "Add stock quote with price, which is not number error" do
      price = "some_string"
      expect {
        post "/api/v1/stock_quotes", params: {ticker: "MSFT", price: price}
      }.to change(StockQuote, :count).by(0)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body).to be_present
      expect(response_body).to eq({"error" => "Price is not a number"})
    end

  end

  describe "PATCH /api/v1/stock_quotes/:id" do
    it "successfully update stock quote" do
      stock_id = apple_stock_quotes[0].id
      expect {
        patch "/api/v1/stock_quotes/#{stock_id}", params: {price: 10, ticker: "MSFT"}
      }.to change(StockQuote, :count).by(0)
      expect(response).to be_present
      expect(response).to have_http_status(:success)
      expect(response_body["id"]).to be_present
      expect(response_body["created_at"]).to be_present
      expect(response_body["price"]).to eq(10)
      expect(response_body["ticker"]).to eq("MSFT")
    end

    it "update stock quote with negative price error" do
      stock_id = apple_stock_quotes[0].id
      expect {
        patch "/api/v1/stock_quotes/#{stock_id}", params: {price: -10}
      }.to change(StockQuote, :count).by(0)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to be_present
      expect(response_body).to eq({"error" => "Price must be greater than 0"})
    end

    it "update stock quote with price as string error" do
      stock_id = apple_stock_quotes[0].id
      expect {
        patch "/api/v1/stock_quotes/#{stock_id}", params: {price: "not_number"}
      }.to change(StockQuote, :count).by(0)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to be_present
      expect(response_body).to eq({"error" => "Price is not a number"})
    end

    it "update stock quote with ticker for company, which does not exist error" do
      stock_id = apple_stock_quotes[0].id
      ticker = "not_exists_ticker"
      expect {
        patch "/api/v1/stock_quotes/#{stock_id}", params: {ticker: ticker}
      }.to change(StockQuote, :count).by(0)
      expect(response).to have_http_status(:not_found)
      expect(response).to be_present
      expect(response_body).to eq({"error" => "Company with ticker #{ticker} not found"})
    end

    it "update stock quote with created_at, which is timestamp error" do
      stock_id = apple_stock_quotes[0].id
      new_created_at = "not_timestamp"
      expect {
        patch "/api/v1/stock_quotes/#{stock_id}", params: {created_at: new_created_at}
      }.to change(StockQuote, :count).by(0)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response).to be_present
      expect(response_body).to eq({"error" => "Provided timestamp is invalid! Provided: #{new_created_at}"})
    end

    it "update stock quote with new created_at, which is correct timestamp" do
      stock_id = apple_stock_quotes[0].id
      new_created_at = "2018.10.13 10:19"
      expect {
        patch "/api/v1/stock_quotes/#{stock_id}", params: {created_at: new_created_at}
      }.to change(StockQuote, :count).by(0)
      expect(response).to be_present
      expect(response).to have_http_status(:success)
      expect(response_body["id"]).to be_present
      expect(response_body["created_at"]).to eq("2018-10-13T10:19:00.000Z")
      expect(response_body["price"]).to be_present
    end
  end

  describe "Get /api/v1/stock_quotes/:id" do
    it "Get stock quote by id, which is valid" do
      stock_id = apple_stock_quotes[0].id
      expect {
        get "/api/v1/stock_quotes/#{stock_id}"
      }.to change(StockQuote, :count).by(0)
      expect(response_body).to be_present
      expect(response).to have_http_status(:success)
      expect(response_body["id"]).to eq(stock_id)
      expect(response_body["created_at"]).to be_present
      expect(response_body["price"]).to be_present
      expect(response_body["ticker"]).to be_present
    end
  end

end
