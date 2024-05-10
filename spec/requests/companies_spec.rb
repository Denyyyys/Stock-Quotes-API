# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Companies', type: :request do
  let!(:companies) do
    [
      FactoryBot.create(:company, name: 'Microsoft', ticker: 'MSFT', origin_country: 'USA'),
      FactoryBot.create(:company, name: 'Apple', ticker: 'AAPL', origin_country: 'USA')
    ]
  end
  let!(:apple_stock_quote) { FactoryBot.create(:stock_quote, price: 102, company: companies[1]) }
  describe 'GET /api/v1/companies' do
    it 'returns all companies' do
      get '/api/v1/companies'
      expect(response).to be_present
      expect(response).to have_http_status(:success)
      expect(response_body).to be_an_instance_of(Array)
      expect(response_body.length).to eq(2)
      response_body_without_ids = response_body.map { |company| company.except('id') }
      companies_without_ids_and_timestamps = companies.map do |company|
        company.attributes.except('id', 'created_at', 'updated_at')
      end
      expect(response_body_without_ids).to match_array(companies_without_ids_and_timestamps)
    end

    it 'returns one company due to limit parameter' do
      get '/api/v1/companies?limit=1'
      expect(response).to be_present
      expect(response).to have_http_status(:success)
      expect(response_body).to be_an_instance_of(Array)
      expect(response_body.length).to eq(1)
      response_body_without_ids = response_body.map { |company| company.except('id') }
      expect(response_body_without_ids).to match_array([{ 'name' => 'Microsoft', 'ticker' => 'MSFT',
                                                          'origin_country' => 'USA' }])
    end

    it 'returns one company due to limit and offset parameter' do
      get '/api/v1/companies?limit=1&offset=1'
      expect(response).to be_present
      expect(response).to have_http_status(:success)
      expect(response_body).to be_an_instance_of(Array)
      expect(response_body.length).to eq(1)
      response_body_without_ids = response_body.map { |company| company.except('id') }
      expect(response_body_without_ids).to match_array([{ 'name' => 'Apple', 'ticker' => 'AAPL',
                                                          'origin_country' => 'USA' }])
    end

    it 'offset is too big, so empty array is returned' do
      get '/api/v1/companies?offset=2'
      expect(response).to be_present
      expect(response).to have_http_status(:success)
      expect(response_body).to be_an_instance_of(Array)
      expect(response_body.length).to eq(0)
    end

    it 'offset is not a number error response' do
      get '/api/v1/companies?offset=notNumber'
      expect(response_body).to eq({ 'error' => 'Offset parameter must be a positive integer or not be present' })
    end

    it 'offset is a negative number error response' do
      get '/api/v1/companies?offset=-1'
      expect(response_body).to eq({ 'error' => 'Offset parameter must be a positive integer or not be present' })
    end

    it 'limit is not a number error response' do
      get '/api/v1/companies?limit=notNumber'
      expect(response_body).to eq({ 'error' => 'Limit parameter must be a positive integer or not be present' })
    end

    it 'limit is a negative number error response' do
      get '/api/v1/companies?limit=-1'
      expect(response_body).to eq({ 'error' => 'Limit parameter must be a positive integer or not be present' })
    end
  end

  describe 'GET /api/v1/companies/:ticker' do
    it 'provided ticker with wrong case' do
      get '/api/v1/companies/msft'
      # response_body_without_id = response_body.except("id")
      expect(response_body_without_id).to eq(
        { 'name' => 'Microsoft', 'ticker' => 'MSFT', 'origin_country' => 'USA' }
      )
    end

    it 'provided ticker is not found' do
      wrong_ticker = 'not_ticker'
      get "/api/v1/companies/#{wrong_ticker}"
      expect(response_body).to eq({ 'error' => "Company with ticker #{wrong_ticker} not found" })
    end
  end

  describe 'POST /api/v1/companies' do
    it 'provided correct data' do
      post '/api/v1/companies', params: { ticker: 'GTLB', name: 'GitLab Inc.', origin_country: 'Ukraine' }
      expect(response).to have_http_status(:created)
      expect(response_body_without_id).to eq({ 'name' => 'GitLab Inc.', 'origin_country' => 'Ukraine',
                                               'ticker' => 'GTLB' })
    end

    it 'ticker is not provided' do
      post '/api/v1/companies', params: { name: 'DELL', origin_country: 'USA' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body_without_id).to eq(
        { 'error' => "Ticker can't be blank, Ticker is too short (minimum is 1 character)" }
      )
    end

  it 'company with provided ticker already exist' do
      post '/api/v1/companies', params: { name: 'Microsoft', ticker: 'MSFT', origin_country: 'USA' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_body_without_id).to eq({ 'error' => 'Ticker has already been taken' })
    end
  end

  describe 'DELETE /api/v1/companies/:ticker' do
    it 'delete created record without stock quotes associated' do
      expect do
        delete '/api/v1/companies/msft'
      end.to change(Company, :count).by(-1)
      expect(StockQuote.count).to eq(1)
      expect(response).to have_http_status(:no_content)
    end

    it 'delete created record with stock quotes associated' do
      expect do
        delete '/api/v1/companies/aapl'
      end.to change(Company, :count).by(-1)
      expect(StockQuote.count).to eq(0)
      expect(response).to have_http_status(:no_content)
    end

    it 'delete created record with incorrect ticker' do
      wrong_ticker = 'not_exist'
      expect do
        delete "/api/v1/companies/#{wrong_ticker}"
      end.to change(Company, :count).by(0)
      expect(StockQuote.count).to eq(1)
      expect(response).to have_http_status(:not_found)
      expect(response_body).to eq({ 'error' => "Company with ticker #{wrong_ticker} not found" })

    end
  end
end
