Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :api do
    namespace :v1 do
      resources :customers, only: [:create, :show]
      resources :transactions, only: [:create, :show]
    end
  end
  mount Sidekiq::Web => "/sidekiq" if Rails.env.development? # mount Sidekiq::Web in your Rails app
end
