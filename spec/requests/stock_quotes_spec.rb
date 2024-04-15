require 'rails_helper'

RSpec.describe "StockQuotes", type: :request do
  describe "GET /destroy" do
    it "returns http success" do
      get "/stock_quotes/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/stock_quotes/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/stock_quotes/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/stock_quotes/show"
      expect(response).to have_http_status(:success)
    end
  end

end
