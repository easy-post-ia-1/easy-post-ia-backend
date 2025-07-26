# frozen_string_literal: true

require 'rails_helper'
require 'jwt'

# Test controller sessions
RSpec.describe Api::V1::Users::SessionsController do
  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let(:company) { create(:company) }
  let(:user) do
    create(:user, username: 'test_user', email: 'test@example.com', password: 'password123', company: company)
  end

  def generate_jwt_token_for_user(user)
    JWT.encode({ sub: user.id }, Rails.application.credentials.devise_jwt_secret_key!)
  end

  describe 'GET #me' do
    context 'when the user is authenticated' do
      it 'returns a successful response with user details' do
        sign_in user
        expect(controller.current_user).to eq(user) # Verify Devise session is set up
        @request.headers['Authorization'] = "Bearer #{generate_jwt_token_for_user(user)}"
        get :me
        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['user']['username']).to eq(user.username)
        expect(json_response['user']['email']).to eq(user.email)
        expect(json_response['user']['role']).to eq('user')
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        get :me
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST #create' do
    context 'when the credentials are valid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
      end

      it 'returns a successful response with user details' do
        post :create, params: { email: user.email, password: 'password123' }
        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['user']['username']).to eq(user.username)
        expect(json_response['user']['email']).to eq(user.email)
        expect(json_response['user']['role']).to eq('user')
      end
    end

    context 'when the credentials are invalid' do
      it 'returns an unauthorized response' do
        user # ensure user is created
        post :create, params: { email: user.email, password: 'wrong_password' }
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to match(/Invalid email or password/i)
      end
    end

    context 'when the email does not exist' do
      it 'returns an unauthorized response' do
        post :create, params: { email: 'nonexistent@example.com', password: 'password123' }
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to match(/Invalid email or password/i)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the user is authenticated' do
      it 'returns a successful response' do
        sign_in user
        expect(controller.current_user).to eq(user) # Verify Devise session is set up
        @request.headers['Authorization'] = "Bearer #{generate_jwt_token_for_user(user)}"
        delete :destroy
        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(200)
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        delete :destroy
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
