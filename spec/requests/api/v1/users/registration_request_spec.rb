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
          username: { type: :string, description: 'The username of the user', example: 'test_user' },
          email: { type: :string, format: :email, description: 'The email address of the user',
                   example: 'test_user@example.com' },
          password: { type: :string, description: 'The password of the user', example: 'password1234' },
          role: {
            type: :string,
            enum: %w[EMPLOYEE ADMIN CUSTOMER],
            description: 'The role of the user (e.g., EMPLOYEE, ADMIN, CUSTOMER)',
            example: 'EMPLOYEE'
          }
        },
        required: %w[username email password role]
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
                   required: ['id', 'username', 'email', 'role']
                 }
               },
               required: ['status', 'user']

        let(:user) do
          {
            username: 'test_user',
            email: 'test_user@example.com',
            password: 'password1234',
            role: 'EMPLOYEE'
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
            username: '',
            email: 'invalid_email',
            password: 'short',
            role: 'INVALID_ROLE'
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
