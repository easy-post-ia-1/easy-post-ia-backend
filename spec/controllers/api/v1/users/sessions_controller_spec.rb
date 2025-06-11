# frozen_string_literal: true

require 'rails_helper'

# Test controller sessions
RSpec.describe Api::V1::Users::SessionsController do
  let(:user) { create(:user, role: 'ADMIN', username: 'test_user', email: 'test@example.com', password: 'password123') }

  describe 'GET #me' do
    context 'when the user is authenticated' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
      end

      it 'returns a successful response with user details' do
        get :me
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['user']['id']).to eq(user.id)
        expect(json_response['user']['username']).to eq(user.username)
        expect(json_response['user']['email']).to eq(user.email)
        expect(json_response['user']['role']).to eq(user.role)
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
      it 'returns a successful response with user details' do
        post :create, params: { email: user.email, password: 'password123' }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['user']['id']).to eq(user.id)
        expect(json_response['user']['username']).to eq(user.username)
        expect(json_response['user']['email']).to eq(user.email)
        expect(json_response['user']['role']).to eq(user.role)
      end
    end

    context 'when the credentials are invalid' do
      it 'returns an unauthorized response' do
        post :create, params: { email: user.email, password: 'wrong_password' }
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('Invalid email or password')
      end
    end

    context 'when the email does not exist' do
      it 'returns an unauthorized response' do
        post :create, params: { email: 'nonexistent@example.com', password: 'password123' }
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('Invalid email or password')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the user is authenticated' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user
      end

      it 'returns a successful response' do
        delete :destroy
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
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
