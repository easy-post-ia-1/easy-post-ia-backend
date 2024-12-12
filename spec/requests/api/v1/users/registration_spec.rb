# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Registration Swagger' do
  path 'api/v1/users/signup' do
    post 'Creates a user registration' do
      tags 'Users'
      consumes 'application/json'

      # Define parameters
      parameter name: :username, in: :body, schema: { type: :string }
      parameter name: :email, in: :body, schema: { type: :string }
      parameter name: :password, in: :body, schema: { type: :string }
      parameter name: :role, in: :body, schema: { type: :string }

      response '201', 'user created' do
        let(:username) { 'test_user2' }
        let(:email) { 'test_user2@example.com' }
        let(:password) { 'password1234' }
        let(:role) { 'EMPLOYEE' }

        run_test!
      end
      pending 'Pending test helper'

      # response '401', 'authentication failed' do
      #   let(:Authorization) { "Basic #{Base64.strict_encode64('bogus:bogus')}" }
      #
      #   run_test!
      # end
      #
      # response '422', 'invalid request' do
      #   let(:username) { '' }
      #   let(:email) { 'invalid_email' }
      #   let(:password) { 'short' }
      #   let(:role) { 'INVALID_ROLE' }
      #
      #   run_test!
      # end
    end
  end
end
