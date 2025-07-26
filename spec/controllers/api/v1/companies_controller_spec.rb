# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CompaniesController do
  let!(:company) { create(:company) }
  let!(:company_employee) { create(:company) }

  let(:admin) { create(:user, role: 'ADMIN', username: 'admin_user', email: 'admin@example.com') }
  let(:employee) { create(:user, role: 'EMPLOYEE', username: 'emp_user', email: 'employee@example.com') }

  let!(:admin_team) { create(:team, company: company) }
  let!(:employee_team) { create(:team, company: company_employee) }

  let!(:admin_team_member) { create(:team_member, user: admin, team: admin_team) }
  let!(:employee_team_member) { create(:team_member, user: employee, team: employee_team) }

  let!(:twitter_credential) { create(:twitter_credential, company: company) }
  let!(:twitter_credential_employee) { create(:twitter_credential, company: company_employee) }

  describe 'GET #company_social_status' do
    context 'when the user is authenticated and has a company' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'returns a successful response with social network status' do
        get :social_network_status
        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['social_networks']).to include('twitter')
        expect(json_response['social_networks']['twitter']).to include('has_credentials')
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        get :social_network_status
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when the user has no company' do
      let(:user_without_company) { create(:user, role: 'EMPLOYEE') }

      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in user_without_company
      end

      it 'returns a not found response' do
        get :social_network_status
        expect(response).to have_http_status(:not_found)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('User is not associated with a company.')
      end
    end
  end

  describe 'GET #show' do
    context 'when the company exists' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'returns a successful response' do
        get :show, params: { id: company.id }
        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['company']['id']).to eq(company.id)
        expect(json_response['company']['name']).to eq(company.name)
      end
    end

    context 'when the company does not exist' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'returns a not found response' do
        get :show, params: { id: 9999 }
        expect(response).to have_http_status(:not_found)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('Company not found.')
      end
    end

    context 'when the user is not authenticated' do
      it 'returns an unauthorized response' do
        get :show, params: { id: company.id }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
