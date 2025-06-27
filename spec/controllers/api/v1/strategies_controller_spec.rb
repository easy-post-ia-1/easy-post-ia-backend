require 'rails_helper'

RSpec.describe Api::V1::StrategiesController do
  let(:company) { create(:company) }
  let(:company_employee) { create(:company) }
  let(:team) { create(:team, company: company) }
  let(:team_employee) { create(:team, company: company_employee) }
  let(:admin) { create(:user, role: 'ADMIN', username: 'admin_user', email: 'admin@example.com', company: company) }
  let(:employee) { create(:user, role: 'EMPLOYEE', username: 'emp_user', email: 'employee@example.com', company: company_employee) }
  let(:admin_team_member) { create(:team_member, user: admin, team: team) }
  let(:employee_team_member) { create(:team_member, user: employee, team: team_employee) }
  let!(:strategy_admin) { create(:strategy, team_member: admin_team_member, company: company) }
  let!(:strategy_employee) { create(:strategy, team_member: employee_team_member, company: company_employee) }
  let!(:admin_posts) { create_list(:post, 3, team_member: admin_team_member, strategy: strategy_admin) }
  let!(:employee_posts) { create_list(:post, 2, team_member: employee_team_member, strategy: strategy_employee) }
  let(:invalid_strategy_params) do
    {
      from_schedule: '',
      to_schedule: '',
      description: ''
    }
  end
  let(:valid_strategy_params) do
    {
      from_schedule: '2024-11-26T00:00:00Z',
      to_schedule: '2024-12-26T00:00:00Z',
      description: 'Sample Strategy'
    }
  end

  describe 'GET #index' do
    context 'when the request is valid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'returns a successful response with pagination' do
        get :index, params: { page: 1, page_size: 10 }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['strategies']).to be_an(Array)
        expect(json_response['pagination']).to include('page', 'per_page', 'pages', 'count')
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        get :index
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET #show' do
    context 'when the strategy exists' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in employee
      end

      it 'returns a successful response' do
        get :show, params: { id: strategy_employee.id }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['strategy']['id']).to eq(strategy_employee.id)
        expect(json_response['strategy']['posts']).to be_an(Array)
      end
    end

    context 'when the strategy does not exist' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'returns a not found response' do
        get :show, params: { id: 9999 }
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('Strategy not found')
      end
    end

    context 'when the user is not authorized' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in employee
      end

      it 'returns a not found response' do
        get :show, params: { id: strategy_admin.id }
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('Strategy not found')
      end
    end
  end

  describe 'POST #create' do
    context 'when the request is valid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'creates a new strategy' do
        expect {
          post :create, params: valid_strategy_params
        }.to change(Strategy, :count).by(1)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(201)
        expect(json_response['strategy']['id']).to be_present
      end
    end

    context 'when the request is invalid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'does not create a strategy' do
        expect {
          post :create, params: invalid_strategy_params
        }.not_to change(Strategy, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to be_an(Array)
      end
    end

    context 'when user is not associated with a team' do
      let(:user_without_team) { create(:user, role: 'EMPLOYEE', username: 'no_team_user', email: 'noteam@example.com', company: company) }
      
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user_without_team
      end

      it 'returns an error' do
        post :create, params: valid_strategy_params
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('User is not associated with a team or company')
      end
    end
  end

  describe 'PUT #update' do
    # Skipped: No route for update
  end

  describe 'DELETE #destroy' do
    # Skipped: No route for destroy
  end
end 