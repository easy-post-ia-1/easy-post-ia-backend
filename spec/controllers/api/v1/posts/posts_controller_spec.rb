# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Posts::PostsController do
  let(:team) { create(:team) }
  let(:team_employee) { create(:team) }
  let(:admin) { create(:user, role: 'ADMIN', username: 'admin_user', email: 'admin@example.com') }
  let(:employee) { create(:user, role: 'EMPLOYEE', username: 'emp_user', email: 'employee@example.com') }
  let(:admin_team_member) { create(:team_member, user: admin, team: team) }
  let(:employee_team_member) { create(:team_member, user: employee, team: team_employee) }
  let!(:strategy_admin) { create(:strategy) }
  let!(:strategy_employee) { create(:strategy) }
  let!(:admin_posts) { create_list(:post, 3, team_member: admin_team_member, strategy: strategy_admin) }
  let!(:employee_posts) { create_list(:post, 2, team_member: employee_team_member, strategy: strategy_employee) }
  let(:invalid_post_params) do
    {
      title: '',
      description: '',
      tags: '',
      programmingDateToPost: '',
      teamMemberId: nil
    }
  end
  let(:valid_post_params) do
    {
      title: 'Sample Post',
      description: 'This is a sample post description',
      tags: 'example,post',
      programming_date_to_post: '2024-11-26T00:00:00Z',
      team_member_id: admin_team_member.id
    }
  end

  describe 'GET #index' do
    context 'when the request is valid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
        get :index
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns a list of posts' do
        expect(response.body).to include('posts') # Adjust based on the response structure
      end
    end
  end

  describe 'GET #show' do
    context 'when the post exists' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in employee
        get :show, params: { id: employee_posts[0].id }
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end

      it 'returns the correct post data' do
        expect(response.body).to include(employee_posts[0].title) # Adjust based on response structure
      end
    end

    context 'when the post does not exist' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
        get :show, params: { id: 9999 }
      end

      it 'returns a not found response' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user is not authorized' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in employee
        get :show, params: { id: admin_posts[0].id }
      end

      it 'returns an unauthorized response' do
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns an error message' do
        expect(response.body).to include('You are not authorized to view this post')
      end
    end
  end

  describe 'POST #create' do
    context 'when the request is valid' do
      let!(:initial_count) { Post.count }

      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
        post :create, params: { post: valid_post_params }
      end

      it 'creates a new post' do
        expect(Post.count).to eq(initial_count + 1)
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:created)
      end

      it 'returns the correct post data' do
        expect(response.body).to include('Sample Post') # Adjust based on response structure
      end
    end

    context 'when the request is invalid' do
      let!(:initial_count) { Post.count }

      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
        post :create, params: { post: invalid_post_params }
      end

      it 'does not create a post' do
        expect(Post.count).to eq(initial_count)
      end

      it 'returns an unprocessable entity response' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns the error message' do
        expect(response.body).to include('errors')
      end
    end
  end

  describe 'PUT #update' do
    let(:post) { create(:post) }

    context 'when the request is valid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
        put :update, params: { id: admin_posts[0].id, post: { title: 'Updated Title' } }
      end

      it 'updates the post' do
        admin_posts[0].reload
        expect(admin_posts[0].title).to eq('Updated Title')
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the request is invalid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
        put :update, params: { id: post.id, post: { title: '' } }
      end

      it 'does not update the post' do
        admin_posts[0].reload
        expect(admin_posts[0].title).not_to eq('')
      end

      it 'returns an unprocessable entity response' do
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:initial_count) { Post.count }

    context 'when the request is valid' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
        delete :destroy, params: { id: admin_posts[0].id }
      end

      it 'deletes the post' do
        expect(Post.count).to eq(initial_count - 1)
      end

      it 'returns a successful response' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the post does not exist' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in admin
        delete :destroy, params: { id: 999_979 }
      end

      it 'returns a not found response' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user is not authorized' do
      before do
        @request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in employee
        delete :destroy, params: { id: admin_posts[0].id }
      end

      it 'does not delete the post' do
        expect(Post.exists?(admin_posts[0].id)).to be true
      end

      it 'returns an unauthorized response' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
