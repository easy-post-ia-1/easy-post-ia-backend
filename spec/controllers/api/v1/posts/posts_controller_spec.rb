# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Posts::PostsController do
  let(:team) { create(:team) }
  let(:team_employee) { create(:team) }
  let(:admin) do
    create(:user, role: 'ADMIN', username: 'admin_user', email: 'admin@example.com')
  end
  let(:employee) do
    create(:user, role: 'EMPLOYEE', username: 'emp_user', email: 'employee@example.com')
  end
  let(:admin_team_member) { create(:team_member, user: admin, team: team) }
  let(:employee_team_member) { create(:team_member, user: employee, team: team_employee) }
  let!(:strategy_admin) { create(:strategy, company: team.company, team_member: admin_team_member) }
  let!(:strategy_employee) { create(:strategy, company: team_employee.company, team_member: employee_team_member) }
  let!(:admin_posts) { create_list(:post, 3, team_member: admin_team_member, strategy: strategy_admin) }
  let!(:employee_posts) { create_list(:post, 2, team_member: employee_team_member, strategy: strategy_employee) }
  let(:invalid_post_params) do
    {
      title: '',
      description: '',
      tags: '',
      programming_date_to_post: '',
      team_member_id: nil
    }
  end
  let(:valid_post_params) do
    {
      title: 'Sample Post',
      description: 'This is a sample post description',
      tags: 'example,post',
      category: 'marketing',
      emoji: '📝',
      programming_date_to_post: '2024-11-26T00:00:00Z',
      team_member_id: admin_team_member.id,
      strategy_id: strategy_admin.id
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
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['posts']).to be_an(Array)
        expect(json_response['pagination'].keys).to match_array(%w[page pages count])
      end

      it 'filters posts by date range' do
        from_date = 1.day.ago.iso8601
        to_date = 1.day.from_now.iso8601
        get :index, params: { from_date: from_date, to_date: to_date }
        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['posts']).to be_an(Array)
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
    context 'when the post exists' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in employee
      end

      it 'returns a successful response' do
        get :show, params: { id: employee_posts[0].id }
        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['post']['id']).to eq(employee_posts[0].id)
      end
    end

    context 'when the post does not exist' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'returns a not found response' do
        get :show, params: { id: 9999 }
        expect(response).to have_http_status(:not_found)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('Post not found')
      end
    end

    context 'when the user is not authorized' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in employee
      end

      it 'returns an unauthorized response' do
        get :show, params: { id: admin_posts[0].id }
        expect(response).to have_http_status(:unauthorized)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('You are not authorized to view this post')
      end
    end
  end

  describe 'POST #create' do
    context 'when the request is valid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'creates a new post' do
        expect do
          post :create, params: { post: valid_post_params }
        end.to change(Post, :count).by(1)
        expect(response).to have_http_status(:created)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(201)
        expect(json_response['post']['title']).to eq(valid_post_params[:title])
      end
    end

    context 'when the request is invalid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'does not create a post' do
        expect do
          post :create, params: { post: invalid_post_params }
        end.not_to change(Post, :count)
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to be_an(Array)
      end
    end
  end

  describe 'PUT #update' do
    context 'when the request is valid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'updates the post' do
        put :update, params: { id: admin_posts[0].id, post: { title: 'Updated Title' } }
        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(200)
        expect(json_response['post']['title']).to eq('Updated Title')
      end
    end

    context 'when the request is invalid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'does not update the post' do
        original_title = admin_posts[0].title
        put :update, params: { id: admin_posts[0].id, post: { title: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to be_an(Array)
        admin_posts[0].reload
        expect(admin_posts[0].title).to eq(original_title)
      end
    end

    context 'when the user is not authorized' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in employee
      end

      it 'returns an unauthorized response' do
        put :update, params: { id: admin_posts[0].id, post: { title: 'Updated Title' } }
        expect(response).to have_http_status(:unauthorized)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('You are not authorized to update this post')
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when the user is authorized' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'deletes the post' do
        expect do
          delete :destroy, params: { id: admin_posts[0].id }
        end.to change(Post, :count).by(-1)
        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(200)
      end
    end

    context 'when the user is not authorized' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in employee
      end

      it 'returns an unauthorized response' do
        delete :destroy, params: { id: admin_posts[0].id }
        expect(response).to have_http_status(:unauthorized)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('You are not authorized to delete this post')
      end
    end

    context 'when the post does not exist' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
      end

      it 'returns a not found response' do
        delete :destroy, params: { id: 9999 }
        expect(response).to have_http_status(:not_found)
        json_response = response.parsed_body
        expect(json_response['status']['code']).to eq(422)
        expect(json_response['errors']).to include('Post not found')
      end
    end
  end
end
