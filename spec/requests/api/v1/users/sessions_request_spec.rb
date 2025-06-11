# frozen_string_literal: true

# :nocov:
require 'swagger_helper'

describe 'Users API' do
  path '/api/v1/users/me' do
    get 'Retrieves the current user details' do
      tags 'Users'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'User details retrieved successfully' do
        schema type: :object,
               properties: {
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     username: { type: :string, example: 'test_user' },
                     email: { type: :string, example: 'test_user@example.com' },
                     role: { type: :string, example: 'EMPLOYEE' }
                   },
                   required: ['id', 'username', 'email', 'role']
                 }
               },
               required: ['user']

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        run_test!
      end

      response '401', 'Unauthorized' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Unauthorized' }
               }
        let(:Authorization) { '' }
        run_test!
      end
    end
  end

  path '/api/v1/users/login' do
    post 'Signs in a user' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email, example: 'test_user@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: ['email', 'password']
      }

      response '200', 'User signed in successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     username: { type: :string, example: 'test_user' },
                     email: { type: :string, example: 'test_user@example.com' },
                     role: { type: :string, example: 'EMPLOYEE' }
                   },
                   required: ['id', 'username', 'email', 'role']
                 }
               },
               required: ['status', 'user']

        let(:user) do
          {
            email: 'test_user@example.com',
            password: 'password123'
          }
        end
        run_test!
      end

      response '401', 'Invalid credentials' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusUnauthorized' }
               }
        let(:user) do
          {
            email: 'test_user@example.com',
            password: 'wrong_password'
          }
        end
        run_test!
      end
    end
  end

  path '/api/v1/users/logout' do
    delete 'Signs out a user' do
      tags 'Users'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'User signed out successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' }
               }
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        run_test!
      end

      response '401', 'Unauthorized' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusUnauthorized' }
               }
        let(:Authorization) { '' }
        run_test!
      end
    end
  end
end
# :nocov:
