# frozen_string_literal: true

require 'rails_helper'
require Rails.root.join('app/controllers/concerns/rack_session_fix.rb').to_s

RSpec.describe Api::V1::Users::RegistrationsController do
  include Devise::Test::ControllerHelpers
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, role: 'ADMIN') }
  let(:employee) { create(:user, role: 'EMPLOYEE') }

  let(:valid_params) do
    {
      username: 'test_user2',
      email: 'test_user2@example.com',
      password: 'password1234',
      role: 'EMPLOYEE'
    }
  end

  let(:invalid_params) do
    {
      username: '',
      email: 'invalid_email',
      password: 'short',
      role: 'INVALID_ROLE'
    }
  end

  describe 'POST #create' do
    context 'when the request is valid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user] # rubocop:disable RSpec/InstanceVariable
      end

      it 'creates a user and returns user_json_response with status code 201' do
        post :create, params: valid_params, as: :json
        expect(response).to have_http_status(:created)
        expect(response.parsed_body).to eq(User.find_by(email: valid_params[:email]).user_json_response)
      end
    end

    context 'when the request is invalid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user] # rubocop:disable RSpec/InstanceVariable
        sign_in admin
      end

      it 'does not create a user and returns error messages with status code 422' do
        post :create, params: invalid_params, as: :json

        response_json = response.parsed_body

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response_json).to include('errors')
        expect(response_json['errors']).to include(
          'Email is invalid',
          'Password is too short (minimum is 6 characters)',
          "Username can't be blank",
          'Email is invalid',
          'Role INVALID_ROLE is not a valid role'
        )
      end
    end

    context 'when signing in as an employee' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user] # rubocop:disable RSpec/InstanceVariable
        sign_in employee
      end

      it 'creates a user and returns user_json_response with status code 201' do
        post :create, params: valid_params, as: :json

        response_json = response.parsed_body
        created_user = User.find_by(email: valid_params[:email])

        expect(response).to have_http_status(:created)
        expect(response_json).to eq(created_user.user_json_response)
      end

      it 'verify method enabled? in RackSessionFix::FakeRackSession' do
        expect(RackSessionFix::FakeRackSession.new.enabled?).to be(false)
      end
    end
  end
end
