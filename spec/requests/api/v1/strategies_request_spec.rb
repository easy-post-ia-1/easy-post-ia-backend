# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Strategies API', type: :request do
  include ApiHelpers

  let(:company) { create(:company) }
  let(:team) { create(:team, company: company) }
  let(:user) { create(:user) }
  let(:team_member) { create(:team_member, user: user, team: team) }
  let(:strategy) { create(:strategy, company: company, team_member: team_member) }
  let(:token) { generate_jwt_token_for_user(user) }

  before do
    team_member # Ensure team member is created
  end

  describe 'GET /api/v1/strategies' do
    context 'when authenticated' do
      before do
        get '/api/v1/strategies', headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 200' do
        puts "Response status: #{response.status}"
        puts "Response body: #{response.body[0..500]}"
        expect(response).to have_http_status(:ok)
      end

      it 'returns strategies for the user\'s team' do
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['strategies']).to be_an(Array)
        expect(json_response['pagination']).to be_present
      end

      it 'includes pagination information' do
        json_response = JSON.parse(response.body)
        expect(json_response['pagination']).to include('page', 'pages', 'count')
      end
    end

    context 'when not authenticated' do
      before do
        get '/api/v1/strategies'
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with pagination parameters' do
      before do
        create_list(:strategy, 5, company: company, team_member: team_member)
        get '/api/v1/strategies', params: { page: 1, page_size: 2 }, headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns paginated results' do
        json_response = JSON.parse(response.body)
        expect(json_response['strategies'].length).to eq(2)
        expect(json_response['pagination']['page']).to eq(1)
        expect(json_response['pagination']['pages']).to be > 1
      end
    end
  end

  describe 'GET /api/v1/strategies/:id' do
    context 'when strategy exists' do
      before do
        get "/api/v1/strategies/#{strategy.id}", headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the strategy details' do
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['strategy']['id']).to eq(strategy.id)
        expect(json_response['strategy']['description']).to eq(strategy.description)
      end
    end

    context 'when strategy does not exist' do
      before do
        get '/api/v1/strategies/99999', headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not authenticated' do
      before do
        get "/api/v1/strategies/#{strategy.id}"
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/strategies' do
    let(:valid_params) do
      {
        strategy: {
          description: 'Test Strategy',
          from_schedule: '2024-01-01T00:00:00Z',
          to_schedule: '2024-12-31T23:59:59Z'
        }
      }
    end

    context 'with valid parameters' do
      before do
        post '/api/v1/strategies', params: valid_params, headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 201' do
        expect(response).to have_http_status(:created)
      end

      it 'creates a new strategy' do
        expect(Strategy.count).to eq(2) # Including the one created in let block
      end

      it 'returns the created strategy' do
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(201)
        expect(json_response['strategy']['description']).to eq('Test Strategy')
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) do
        {
          strategy: {
            description: '',
            from_schedule: 'invalid-date'
          }
        }
      end

      before do
        post '/api/v1/strategies', params: invalid_params, headers: { 'Authorization' => "Bearer #{token}" }
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

    context 'when user is not associated with a team' do
      let(:user_without_team) { create(:user) }
      let(:token_without_team) { generate_jwt_token_for_user(user_without_team) }

      before do
        post '/api/v1/strategies', params: valid_params, headers: { 'Authorization' => "Bearer #{token_without_team}" }
      end

      it 'returns status 422' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns an error message' do
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include('User is not associated with a team or company')
      end
    end

    context 'when not authenticated' do
      before do
        post '/api/v1/strategies', params: valid_params
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PUT /api/v1/strategies/:id' do
    let(:update_params) do
      {
        strategy: {
          description: 'Updated Strategy Description'
        }
      }
    end

    context 'with valid parameters' do
      before do
        put "/api/v1/strategies/#{strategy.id}", params: update_params, headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'updates the strategy' do
        strategy.reload
        expect(strategy.description).to eq('Updated Strategy Description')
      end

      it 'returns the updated strategy' do
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['strategy']['description']).to eq('Updated Strategy Description')
      end
    end

    context 'when strategy does not exist' do
      before do
        put '/api/v1/strategies/99999', params: update_params, headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not authenticated' do
      before do
        put "/api/v1/strategies/#{strategy.id}", params: update_params
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'DELETE /api/v1/strategies/:id' do
    context 'when strategy exists' do
      before do
        delete "/api/v1/strategies/#{strategy.id}", headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'deletes the strategy' do
        expect(Strategy.exists?(strategy.id)).to be false
      end
    end

    context 'when strategy does not exist' do
      before do
        delete '/api/v1/strategies/99999', headers: { 'Authorization' => "Bearer #{token}" }
      end

      it 'returns status 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when not authenticated' do
      before do
        delete "/api/v1/strategies/#{strategy.id}"
      end

      it 'returns status 401' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
