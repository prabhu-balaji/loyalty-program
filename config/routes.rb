Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :transactions, only: [:create, :show]
      resources :customers, only: [:create, :show] do
        member do
          post "claim-reward"
          get "customer-rewards"
        end
      end
    end
  end
  mount Sidekiq::Web => "/sidekiq" if Rails.env.development? # mount Sidekiq::Web in your Rails app
end
