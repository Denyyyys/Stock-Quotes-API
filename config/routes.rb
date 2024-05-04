# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  get 'stock_quotes/destroy'
  get 'stock_quotes/create'
  get 'stock_quotes/update'
  get 'stock_quotes/show'
  get 'companies/index'
  get 'companies/create'
  get 'companies/destroy'
  namespace :api do
    namespace :v1 do
      resources :companies, only: %i[index show create destroy], param: :ticker

      resources :stock_quotes, only: %i[destroy create update show] do
        get 'ticker/:ticker', action: :get_by_ticker, on: :collection
        delete 'ticker/:ticker', action: :delete_all_by_ticker, on: :collection
      end
    end
  end
end
