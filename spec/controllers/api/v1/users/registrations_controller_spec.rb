# frozen_string_literal: true

require 'rails_helper'
# require Rails.root.join('app/controllers/concerns/rack_session_fix.rb').to_s
#
RSpec.describe Api::V1::Users::RegistrationsController do
  include Devise::Test::ControllerHelpers
  include Devise::Test::IntegrationHelpers

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  let(:company) { create(:company) }
  let(:admin) { 
    user = create(:user, company: company)
    user.add_role(:admin)
    user
  }
  let(:employee) { 
    user = create(:user, company: company)
    user.add_role(:employee)
    user
  }

  let(:valid_user_params) do
    {
      username: 'test_user',
      email: 'test@example.com',
      password: 'password123',
      role: 'EMPLOYEE',
      company_id: company.id
    }
  end

  let(:invalid_user_params) do
    {
      username: '',
      email: 'invalid_email',
      password: '',
      company_id: company.id
    }
  end

  describe 'POST #create' do
    context 'when the request is valid' do
      it 'creates a new user' do
        expect {
          post :create, params: valid_user_params
          puts response.body
        }.to change(User, :count).by(1)
        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(201)
        expect(json_response['user']['username']).to eq(valid_user_params[:username])
        expect(json_response['user']['email']).to eq(valid_user_params[:email])
        expect(json_response['user']['role']).to eq('employee')
      end

      it 'assigns the role using Rolify' do
        post :create, params: valid_user_params
        puts response.body
        created_user = User.find_by(email: valid_user_params[:email])
        expect(created_user).not_to be_nil
        expect(created_user.has_role?(:employee)).to be true
        expect(created_user.roles.first.name).to eq('employee')
      end
    end

    context 'when the request is invalid' do
      it 'does not create a user' do
        expect {
          post :create, params: invalid_user_params
          puts response.body
        }.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to be_an(Array)
      end
    end

    context 'when the email is already taken' do
      before { 
        user = create(:user, email: valid_user_params[:email], company: company, username: 'other_user')
        user.add_role(:employee)
      }
      it 'does not create a user' do
        post :create, params: valid_user_params
        puts response.body
        json_response = JSON.parse(response.body)
        expect(json_response['errors'].join).to match(/Email has already been taken|email has already been taken|Email Email can't be blank/i)
      end
    end

    context 'when the username is already taken' do
      before { 
        user = create(:user, username: valid_user_params[:username], company: company, email: 'other@example.com')
        user.add_role(:employee)
      }
      it 'does not create a user' do
        post :create, params: valid_user_params
        puts response.body
        json_response = JSON.parse(response.body)
        expect(json_response['errors'].join).to match(/Username has already been taken|username has already been taken|Username Username can't be blank/i)
      end
    end

    context 'when signing in as an employee' do
      before do
        sign_in employee
      end

      it 'creates a user and returns user_json_response with status code 201' do
        post :create, params: valid_user_params
        puts response.body
        response_json = response.parsed_body
        created_user = User.find_by(email: valid_user_params[:email])
        expect(response).to have_http_status(:created)
        expect(response_json['status']['code']).to eq(201)
        expect(response_json['user']).to eq(created_user.user_json_response)
      end

      it 'verify method enabled? in RackSessionFix::FakeRackSession' do
        expect(RackSessionFix::FakeRackSession.new.enabled?).to be(false)
      end
    end
  end
end
