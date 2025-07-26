# frozen_string_literal: true

require 'swagger_helper'

describe 'Sessions API' do
  path '/api/v1/users/login' do
    post 'User login (login)' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              username: { type: :string },
              password: { type: :string }
            },
            required: %w[username password]
          }
        },
        required: ['user']
      }
      response '200', 'User signed in successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 user: { type: :object }
               },
               required: %w[status user]
        let(:user) { { user: { username: 'e2e_login_user', password: 'E2eLoginPassword!2025' } } }
        run_test!
      end
      response '401', 'Invalid credentials' do
        let(:user) { { user: { username: 'e2e_login_user', password: 'wrongpassword' } } }
        run_test!
      end
    end
  end

  path '/api/v1/users/sign_out' do
    delete 'User logout (sign out)' do
      tags 'Users'
      produces 'application/json'
      security [Bearer: []]
      response '200', 'User signed out successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' }
               },
               required: %w[status]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        run_test!
      end
      response '401', 'Unauthorized' do
        let(:Authorization) { '' }
        run_test!
      end
    end
  end

  path '/api/v1/me' do
    get 'Get current user profile' do
      tags 'Users'
      produces 'application/json'
      security [Bearer: []]
      response '200', 'User profile retrieved' do
        schema type: :object,
               properties: {
                 user: { type: :object }
               },
               required: %w[user]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        run_test!
      end
      response '401', 'Unauthorized' do
        let(:Authorization) { '' }
        run_test!
      end
    end
  end
end
