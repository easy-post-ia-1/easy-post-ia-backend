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

  let(:company) { create(:company, code: 'TESTCODE') }
  let(:admin) do
    user = create(:user)
    user.add_role(:admin)
    user
  end
  let(:employee) do
    user = create(:user)
    user.add_role(:employee)
    user
  end

  let(:valid_user_params) do
    {
      user: {
        username: 'test_user',
        email: 'test@example.com',
        password: 'password123',
        role: 'EMPLOYEE',
        company_code: company.code,
        team_code: 'TEAM001',
        team_name: 'Test Team'
      }
    }
  end

  let(:invalid_user_params) do
    {
      user: {
        username: '',
        email: 'invalid_email',
        password: '',
        company_code: company.code,
        team_code: 'TEAM001'
      }
    }
  end

  describe 'POST #create' do
    context 'when the request is valid' do
      it 'creates a new user' do
        expect do
          post :create, params: valid_user_params
          puts response.body
        end.to change(User, :count).by(1)
        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(201)
        expect(json_response['user']['username']).to eq(valid_user_params[:user][:username])
        expect(json_response['user']['email']).to eq(valid_user_params[:user][:email])
        expect(json_response['user']['role']).to eq('employee')
      end

      it 'assigns the role using Rolify' do
        post :create, params: valid_user_params
        puts response.body
        created_user = User.find_by(email: valid_user_params[:user][:email])
        expect(created_user).not_to be_nil
        expect(created_user.has_role?(:employee)).to be true
        expect(created_user.roles.first.name).to eq('employee')
      end
    end

    context 'when the request is invalid' do
      it 'does not create a user' do
        expect do
          post :create, params: invalid_user_params
          puts response.body
        end.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to be_an(Array)
      end
    end

    context 'when the email is already taken' do
      before do
        user = create(:user, email: valid_user_params[:user][:email], username: 'other_user')
        user.add_role(:employee)
      end

      it 'does not create a user' do
        post :create, params: valid_user_params
        puts response.body
        json_response = response.parsed_body
        expect(json_response['errors'].join).to match(/Email This email is already registered|Email has already been taken|email has already been taken|Email Email can't be blank/i)
      end
    end

    context 'when the username is already taken' do
      before do
        user = create(:user, username: valid_user_params[:user][:username], email: 'other@example.com')
        user.add_role(:employee)
      end

      it 'does not create a user' do
        post :create, params: valid_user_params
        puts response.body
        json_response = response.parsed_body
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
        created_user = User.find_by(email: valid_user_params[:user][:email])
        expect(response).to have_http_status(:created)
        expect(response_json['status']['code']).to eq(201)
        expect(response_json['user']).to eq(created_user.user_json_response)
      end

      it 'verify method enabled? in RackSessionFix::FakeRackSession' do
        expect(RackSessionFix::FakeRackSession.new.enabled?).to be(false)
      end
    end

    context 'when the company_code is invalid' do
      it 'does not create a user and returns invalid company code error' do
        invalid_params = valid_user_params.deep_dup
        invalid_params[:user][:company_code] = 'INVALIDCODE'
        expect do
          post :create, params: invalid_params
        end.not_to change(User, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response['errors']).to include('Invalid company code')
      end
    end
  end
end
