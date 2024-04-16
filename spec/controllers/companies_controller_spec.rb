require 'rails_helper'
require_relative '../../app/controllers/api/v1/companies_controller'

RSpec.describe Api::V1::CompaniesController, type: :controller do
  let(:max_pagination_limit) { Api::V1::CompaniesController::MAX_PAGINATION_LIMIT }
  describe 'Limit functionality' do
    it 'MAX_PAGINATION_LIMIT is bigger than 0' do
      expect(max_pagination_limit).to be >= 0
    end
  end

  describe 'GET index' do
    let(:larger_limit) { max_pagination_limit + 10 }
    let(:within_limit) { [max_pagination_limit - 10, 1].max }

    it 'limit provided bigger than MAX_PAGINATION_LIMIT' do
      expect(Company).to receive(:limit).with(max_pagination_limit).and_call_original
      get :index,params: {limit: larger_limit}
    end

    it 'limit provided is bigger than 0 and smaller than MAX_PAGINATION_LIMIT' do
      expect(Company).to receive(:limit).with(within_limit).and_call_original
      get :index,params: {limit: within_limit}
    end
  end
end
