# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Companies API', type: :request do
  include ApiHelpers

  let(:company) { create(:company) }
  let(:team) { create(:team, company: company) }
  let(:user) { create(:user) }
  let(:team_member) { create(:team_member, user: user, team: team) }
  let(:token) { generate_jwt_token_for_user(user) }

  before do
    team_member # Ensure team member is created
  end

  describe 'GET /api/v1/companies/company_social_status/me' do
    context 'when authenticated and user is associated with a company' do
      context 'when company has complete Twitter credentials' do
        before do
          create(:credentials_twitter, company: company)
          get '/api/v1/companies/company_social_status/me', headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'returns status 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns has_credentials: true for Twitter' do
          json_response = JSON.parse(response.body)
          expect(json_response['status']['code']).to eq(200)
          expect(json_response['social_networks']['twitter']['has_credentials']).to be true
        end
      end

      context 'when company has incomplete Twitter credentials' do
        before do
          create(:credentials_twitter, company: company, api_key: nil)
          get '/api/v1/companies/company_social_status/me', headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'returns status 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns has_credentials: false for Twitter' do
          json_response = JSON.parse(response.body)
          expect(json_response['status']['code']).to eq(200)
          expect(json_response['social_networks']['twitter']['has_credentials']).to be false
        end
      end

      context 'when company has no Twitter credentials record' do
        before do
          get '/api/v1/companies/company_social_status/me', headers: { 'Authorization' => "Bearer #{token}" }
        end

        it 'returns status 200' do
          expect(response).to have_http_status(:ok)
        end

        it 'returns has_credentials: false for Twitter' do
          json_response = JSON.parse(response.body)
          expect(json_response['status']['code']).to eq(200)
          expect(json_response['social_networks']['twitter']['has_credentials']).to be false
        end
      end
    end

    context 'when authenticated and user is not associated with a company' do
      let(:user_without_company) { create(:user) }
      let(:token_without_company) { generate_jwt_token_for_user(user_without_company) }

      before do
        get '/api/v1/companies/company_social_status/me', headers: { 'Authorization' => "Bearer #{token_without_company}" }
      end

      it 'returns status 404' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('User not associated with a company')
      end
    end

    context 'when not authenticated' do
      before do
        get '/api/v1/companies/company_social_status/me'
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/companies/:id' do
    context 'when company exists' do
      before do
        get "/api/v1/companies/#{company.id}", headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the company details' do
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['company']['id']).to eq(company.id)
        expect(json_response['company']['name']).to eq(company.name)
      end
    end

    context 'when company does not exist' do
      before do
        get '/api/v1/companies/99999', headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 404' do
        expect(response).to have_http_status(:not_found)
      end

      it 'returns an error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('Company not found')
      end
    end

    context 'when not authenticated' do
      before do
        get "/api/v1/companies/#{company.id}"
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/companies' do
    let(:valid_params) do
      {
        company: {
          name: 'New Company',
          code: 'NEWCOMP'
        }
      }
    end

    context 'with valid parameters' do
      before do
        post '/api/v1/companies', params: valid_params, headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 201' do
        expect(response).to have_http_status(:created)
      end

      it 'creates a new company' do
        expect(Company.count).to eq(2) # Including the one created in let block
      end

      it 'returns the created company' do
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(201)
        expect(json_response['company']['name']).to eq('New Company')
        expect(json_response['company']['code']).to eq('NEWCOMP')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          company: {
            name: '',
            code: ''
          }
        }
      end

      before do
        post '/api/v1/companies', params: invalid_params, headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns validation errors' do
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to be_an(Array)
        expect(json_response['errors']).not_to be_empty
      end
    end

    context 'when not authenticated' do
      before do
        post '/api/v1/companies', params: valid_params
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /api/v1/companies/:id' do
    let(:update_params) do
      {
        company: {
          name: 'Updated Company Name'
        }
      }
    end

    context 'with valid parameters' do
      before do
        put "/api/v1/companies/#{company.id}", params: update_params, headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'updates the company' do
        company.reload
        expect(company.name).to eq('Updated Company Name')
      end

      it 'returns the updated company' do
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['company']['name']).to eq('Updated Company Name')
      end
    end

    context 'when company does not exist' do
      before do
        put '/api/v1/companies/99999', params: update_params, headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not authenticated' do
      before do
        put "/api/v1/companies/#{company.id}", params: update_params
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/companies/:id' do
    context 'when company exists' do
      before do
        delete "/api/v1/companies/#{company.id}", headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'deletes the company' do
        expect(Company.exists?(company.id)).to be false
      end
    end

    context 'when company does not exist' do
      before do
        delete '/api/v1/companies/99999', headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not authenticated' do
      before do
        delete "/api/v1/companies/#{company.id}"
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end 