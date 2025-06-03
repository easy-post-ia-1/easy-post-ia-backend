# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  draw :madmin
  root to: 'madmin#show'
  mount Sidekiq::Web => '/sidekiq' # mount Sidekiq::Web in your Rails app

  get 'up' => 'rails/health#show', as: :rails_health_check
  namespace :api do
    namespace :v1 do
      get '/me/company_social_status', to: 'companies#social_network_status'
      resources :companies, only: [:show] # Provides GET /api/v1/companies/:id
      resources :posts, controller: 'posts/posts', only: %i[index show create update destroy]
      post '/strategy/create', to: 'strategies#create'

      mount Rswag::Ui::Engine => '/docs' unless Rails.env.production?
      mount Rswag::Api::Engine => '/docs' unless Rails.env.production?
      # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

      # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
      # Can be used by load balancers and uptime monitors to verify that the app is live.

      # Defines the root path route ("/")

      get '/users/healthcheck', to: 'users/healthcheck#show'
    end
  end
  devise_for :users,
             defaults: { format: :json },
             singular: :user,
             path: 'api/v1/users',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'api/v1/users/sessions',
               registrations: 'api/v1/users/registrations'
             }

  devise_scope :user do
    get 'api/v1/users/me', to: 'api/v1/users/sessions#me'
  end
end
