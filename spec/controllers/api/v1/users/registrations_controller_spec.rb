# frozen_string_literal: true

require 'rails_helper'
# require Rails.root.join('app/controllers/concerns/rack_session_fix.rb').to_s
#
RSpec.describe Api::V1::Users::RegistrationsController do
  include Devise::Test::ControllerHelpers
  include Devise::Test::IntegrationHelpers

  let(:admin) { create(:user, role: 'ADMIN') }
  let(:employee) { create(:user, role: 'EMPLOYEE') }

  let(:valid_user_params) do
    {
      username: 'test_user',
      email: 'test@example.com',
      password: 'password123',
      role: 'EMPLOYEE'
    }
  end

  let(:invalid_user_params) do
    {
      username: '',
      email: 'invalid_email',
      password: '',
      role: 'INVALID_ROLE'
    }
  end

  describe 'POST #create' do
    context 'when the request is valid' do
      it 'creates a new user' do
        expect {
          post :create, params: { user: valid_user_params }
        }.to change(User, :count).by(1)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(201)
        expect(json_response['user']['username']).to eq(valid_user_params[:username])
        expect(json_response['user']['email']).to eq(valid_user_params[:email])
        expect(json_response['user']['role']).to eq(valid_user_params[:role])
      end
    end

    context 'when the request is invalid' do
      it 'does not create a user' do
        expect {
          post :create, params: { user: invalid_user_params }
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to be_an(Array)
      end
    end

    context 'when the email is already taken' do
      let!(:existing_user) { create(:user, email: 'test@example.com') }

      it 'does not create a user' do
        expect {
          post :create, params: { user: valid_user_params }
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('Email has already been taken')
      end
    end

    context 'when the username is already taken' do
      let!(:existing_user) { create(:user, username: 'test_user') }

      it 'does not create a user' do
        expect {
          post :create, params: { user: valid_user_params }
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('Username has already been taken')
      end
    end

    context 'when signing in as an employee' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user] # rubocop:disable RSpec/InstanceVariable
        sign_in employee
      end

      it 'creates a user and returns user_json_response with status code 201' do
        post :create, params: valid_user_params, as: :json

        response_json = response.parsed_body
        created_user = User.find_by(email: valid_user_params[:email])

        expected_response = { 'status' => { 'code' => 201, 'message' => 'Welcome! You have signed up successfully.' },
                              'user' => created_user.user_json_response }
        expect(response).to have_http_status(:created)
        expect(response_json).to eq(expected_response)
      end

      it 'verify method enabled? in RackSessionFix::FakeRackSession' do
        expect(RackSessionFix::FakeRackSession.new.enabled?).to be(false)
      end
    end
  end
end
