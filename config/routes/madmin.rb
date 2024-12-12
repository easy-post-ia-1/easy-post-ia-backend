# frozen_string_literal: true

# Below are the routes for madmin
namespace :madmin do
  resources :companies
  resources :posts
  resources :teams
  resources :team_members
  resources :users
  resources :jwt_denylists
  root to: 'dashboard#show'
end
