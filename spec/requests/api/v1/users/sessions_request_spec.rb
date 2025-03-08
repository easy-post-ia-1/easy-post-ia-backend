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
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 200 },
                     message: { type: :string, example: 'User details retrieved successfully' }
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
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }

        xit do |response|
          expect(response.status).to eq(200)
          expect(response.content_type).to eq('application/json')
          json_response = JSON.parse(response.body)
          expect(json_response['user']).to include('id', 'username', 'email', 'role')
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

        let(:Authorization) { '' }

        xit do |response|
          expect(response.status).to eq(401)
          expect(response.content_type).to eq('application/json')
          json_response = JSON.parse(response.body)
          expect(json_response['error']).to eq('Unauthorized')
        end
      end
    end
  end
end
# :nocov:
