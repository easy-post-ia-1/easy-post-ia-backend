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

      response '201', 'User successfully created' do
        let(:user) do
          {
            username: 'test_user',
            email: 'test_user@example.com',
            password: 'password1234',
            role: 'EMPLOYEE'
          }
        end

        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 201 },
                     message: { type: :string, example: 'User successfully created' }
                   }
                 },
                 user: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     username: { type: :string, example: 'test_user' },
                     email: { type: :string, example: 'test_user@example.com' },
                     role: { type: :string, example: 'EMPLOYEE' }
                   }
                 }
               }

        xit do |response|
          expect(response.status).to eq(201)
          expect(response.content_type).to eq('application/json')
          json_response = JSON.parse(response.body)
          expect(json_response['status']['code']).to eq(201)
          expect(json_response['status']['message']).to eq('User successfully created')
          expect(json_response['user']).to include('id', 'username', 'email', 'role')
        end
      end

      response '422', 'Invalid request or validation errors' do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 422 },
                     message: { type: :string, example: 'Validation failed' }
                   }
                 },
                 errors: {
                   type: :array,
                   items: { type: :string },
                   example: ['Username can\'t be blank', 'Email is invalid', 'Role is not included in the list']
                 }
               }

        let(:user) do
          {
            username: '',
            email: 'invalid_email',
            password: 'short',
            role: 'INVALID_ROLE'
          }
        end

        xit do |response|
          expect(response.status).to eq(422)
          expect(response.content_type).to eq('application/json')
          json_response = JSON.parse(response.body)
          expect(json_response['status']['code']).to eq(422)
          expect(json_response['status']['message']).to eq('Validation failed')
          expect(json_response['errors']).to be_an(Array)
        end
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
