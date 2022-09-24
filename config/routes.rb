Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :customers, only: [:create, :show]
      resources :transactions, only: [:create, :show]
      post "/customers/:id/claim-reward", to: "customers#claim_reward"
    end
  end
  mount Sidekiq::Web => "/sidekiq" if Rails.env.development? # mount Sidekiq::Web in your Rails app
end
