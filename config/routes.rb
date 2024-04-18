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
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  # get "up" => "rails/health#show", as: :rails_health_check
  namespace :api do
    namespace :v1 do
      resources :companies, only: [:index, :show, :create, :destroy], param: :ticker

      resources :stock_quotes, only: [:destroy, :create, :update, :show] do
        get 'ticker/:ticker', action: :get_by_ticker, on: :collection
        delete 'ticker/:ticker', action: :delete_all_by_ticker, on: :collection
      end
    end
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
