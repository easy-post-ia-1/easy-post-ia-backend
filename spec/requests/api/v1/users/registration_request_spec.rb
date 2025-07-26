# frozen_string_literal: true

# :nocov:

require 'swagger_helper'

describe 'Users API' do
  path '/api/v1/users/signup' do
    post 'Creates a new user registration' do
      tags 'Users'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              username: { type: :string, description: 'The username of the user', example: 'test_user' },
              email: { type: :string, format: :email, description: 'The email address of the user', example: 'test_user@example.com' },
              password: { type: :string, description: 'The password of the user (min 6, max 128 characters)', example: 'Password1234', minLength: 6, maxLength: 128 },
              role: {
                type: :string,
                enum: %w[EMPLOYEE ADMIN CUSTOMER],
                description: 'The role of the user (e.g., EMPLOYEE, ADMIN, CUSTOMER)',
                example: 'EMPLOYEE'
              },
              company_code: { type: :string, description: 'The code of the company', example: 'COMPANY123' },
              team_code: { type: :string, description: 'The code of the team', example: 'TEAM456' }
            },
            required: %w[username email password role company_code team_code]
          }
        },
        required: ['user']
      }

      response '201', 'User created successfully' do
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
                   required: %w[id username email role]
                 }
               },
               required: %w[status user]

        let(:user) do
          {
            user: {
              username: ENV['E2E_TEST_USERNAME'] || 'test_user',
              email: ENV['E2E_TEST_EMAIL'] || 'test_user@example.com',
              password: ENV['E2E_TEST_PASSWORD'] || 'Password1234',
              role: 'EMPLOYER',
              company_code: 'COMPANY123',
              team_code: 'TEAM456'
            }
          }
        end
        run_test!
      end

      response '422', 'Validation error' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusError' },
                 errors: { type: :array, items: { type: :string } }
               }
        let(:user) do
          {
            user: {
              username: '',
              email: 'invalid_email',
              password: 'short',
              role: 'INVALID_ROLE',
              company_code: '',
              team_code: ''
            }
          }
        end
        run_test!
      end

      response '401', 'Unauthorized access' do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 401 },
                     message: { type: :string, example: 'Unauthorized' }
                   }
                 },
                 error: { type: :string, example: 'Invalid credentials' }
               }

        let(:Authorization) { "Basic #{Base64.strict_encode64('bogus:bogus')}" }

        xit do |response|
          expect(response.status).to eq(401)
          expect(response.content_type).to eq('application/json')
          json_response = JSON.parse(response.body)
          expect(json_response['status']['code']).to eq(401)
          expect(json_response['status']['message']).to eq('Unauthorized')
        end
      end
    end
  end
end
# :nocov:
