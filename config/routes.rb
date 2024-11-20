# frozen_string_literal: true

Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check
  namespace :api do
    namespace :v1 do
      mount Rswag::Ui::Engine => '/docs'
      mount Rswag::Api::Engine => '/docs'
      # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

      # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
      # Can be used by load balancers and uptime monitors to verify that the app is live.

      # Defines the root path route ("/")
      # root "posts#index"
      #

      namespace :users do
        get 'healthcheck', to: 'healthcheck#show'
      end
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
end
