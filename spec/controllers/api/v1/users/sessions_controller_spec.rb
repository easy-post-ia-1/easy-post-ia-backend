# frozen_string_literal: true

require 'rails_helper'

# Test controller sessions
RSpec.describe Api::V1::Users::SessionsController do
  let(:user) { create(:user, email: 'test20@mail.com', username: 'test20', role: 'ADMIN') }

  describe 'POST #create' do
    context 'with valid credentials' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user] # rubocop:disable RSpec/InstanceVariable
        sign_in user
        post :create
      end

      it 'returns a successful sign-in response with user details' do
        expect(response).to have_http_status(:ok)

        expect(response.parsed_body['status']).to include(
          'code' => 200,
          'message' => 'Signed in successfully.'
        )

        expect(response.parsed_body['user']).to include(
          'email' => 'test20@mail.com',
          'username' => 'test20',
          'role' => 'ADMIN'
        )
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the user is signed in' do
      before do
        token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
        request.headers['Authorization'] = "Bearer #{token}"
        delete :destroy
      end

      it 'returns a successful sign-out response' do
        expect(response).to have_http_status(:ok)

        expect(response.parsed_body['status']).to include(
          'code' => 200,
          'message' => I18n.t('devise.sessions.signed_out')
        )
      end
    end

    context 'when there is no valid user token' do
      before do
        delete :destroy
      end

      it 'returns an unauthorized response for already signed-out user' do
        expect(response).to have_http_status(:unauthorized)

        expect(response.parsed_body['status']).to include(
          'code' => 401,
          'message' => I18n.t('devise.sessions.already_signed_out')
        )
      end
    end
  end
end
