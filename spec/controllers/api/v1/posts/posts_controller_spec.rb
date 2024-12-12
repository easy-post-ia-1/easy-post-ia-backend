# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::Posts::PostsController do
  pending 'Pending test helper'
  # include Devise::Test::ControllerHelpers
  # include Devise::Test::IntegrationHelpers
  #
  # let(:admin) { create(:user, role: 'ADMIN') }
  # let(:employee) { create(:user, role: 'EMPLOYEE') }
  # # let(:valid_post_params) { create(:post) }
  #
  # let(:invalid_post_params) do
  #   {
  #     title: '',
  #     description: '',
  #     tags: '',
  #     programmingDateToPost: '',
  #     teamMemberId: nil
  #   }
  # end
  #
  # describe 'GET #index' do
  #   context 'when the request is valid' do
  #     before do
  #       @request.env['devise.mapping'] = Devise.mappings[:user]
  #       sign_in admin
  #       get :index
  #     end
  #
  #     it 'returns a successful response' do
  #       expect(response).to have_http_status(:ok)
  #     end
  #
  #     it 'returns a list of posts' do
  #       expect(response.body).to include('posts') # Adjust based on the response structure
  #     end
  #   end
  # end
  #
  # describe 'GET #show' do
  #   let(:post) { create(:post) } # Assuming you have a factory for posts
  #
  #   context 'when the post exists' do
  #     before do
  #       @request.env['devise.mapping'] = Devise.mappings[:user]
  #       sign_in admin
  #       get :show, params: { id: post.id }
  #     end
  #
  #     it 'returns a successful response' do
  #       expect(response).to have_http_status(:ok)
  #     end
  #
  #     it 'returns the correct post data' do
  #       expect(response.body).to include(post.title) # Adjust based on response structure
  #     end
  #   end
  #
  #   context 'when the post does not exist' do
  #     before do
  #       @request.env['devise.mapping'] = Devise.mappings[:user]
  #       sign_in admin
  #       get :show, params: { id: 99_999 }
  #     end
  #
  #     it 'returns a not found response' do
  #       expect(response).to have_http_status(:not_found)
  #     end
  #   end
  # end
  #
  # describe 'POST #create' do
  #   context 'when the request is valid' do
  #     before do
  #       @request.env['devise.mapping'] = Devise.mappings[:user]
  #       sign_in admin
  #       post :create, params: { post: valid_post_params }
  #     end
  #
  #     it 'creates a new post' do
  #       expect(Post.count).to eq(1)
  #     end
  #
  #     it 'returns a successful response' do
  #       expect(response).to have_http_status(:created)
  #     end
  #
  #     it 'returns the correct post data' do
  #       expect(response.body).to include('Sample Post') # Adjust based on response structure
  #     end
  #   end
  #
  #   context 'when the request is invalid' do
  #     before do
  #       @request.env['devise.mapping'] = Devise.mappings[:user]
  #       sign_in admin
  #       post :create, params: { post: invalid_post_params }
  #     end
  #
  #     it 'does not create a post' do
  #       expect(Post.count).to eq(0)
  #     end
  #
  #     it 'returns an unprocessable entity response' do
  #       expect(response).to have_http_status(:unprocessable_entity)
  #     end
  #
  #     it 'returns the error message' do
  #       expect(response.body).to include('errors')
  #     end
  #   end
  # end
  #
  # describe 'PUT #update' do
  #   let(:post) { create(:post) }
  #
  #   context 'when the request is valid' do
  #     before do
  #       @request.env['devise.mapping'] = Devise.mappings[:user]
  #       sign_in admin
  #       put :update, params: { id: post.id, post: { title: 'Updated Title' } }
  #     end
  #
  #     it 'updates the post' do
  #       post.reload
  #       expect(post.title).to eq('Updated Title')
  #     end
  #
  #     it 'returns a successful response' do
  #       expect(response).to have_http_status(:ok)
  #     end
  #   end
  #
  #   context 'when the request is invalid' do
  #     before do
  #       @request.env['devise.mapping'] = Devise.mappings[:user]
  #       sign_in admin
  #       put :update, params: { id: post.id, post: { title: '' } }
  #     end
  #
  #     it 'does not update the post' do
  #       post.reload
  #       expect(post.title).not_to eq('')
  #     end
  #
  #     it 'returns an unprocessable entity response' do
  #       expect(response).to have_http_status(:unprocessable_entity)
  #     end
  #   end
  # end
  #
  # describe 'DELETE #destroy' do
  #   let!(:post) { create(:post) }
  #
  #   context 'when the request is valid' do
  #     before do
  #       @request.env['devise.mapping'] = Devise.mappings[:user]
  #       sign_in admin
  #       delete :destroy, params: { id: post.id }
  #     end
  #
  #     it 'deletes the post' do
  #       expect(Post.count).to eq(0)
  #     end
  #
  #     it 'returns a successful response' do
  #       expect(response).to have_http_status(:no_content)
  #     end
  #   end
  #
  #   context 'when the post does not exist' do
  #     before do
  #       @request.env['devise.mapping'] = Devise.mappings[:user]
  #       sign_in admin
  #       delete :destroy, params: { id: 99_999 }
  #     end
  #
  #     it 'returns a not found response' do
  #       expect(response).to have_http_status(:not_found)
  #     end
  #   end
  # end
  #
  describe 'GET' do
    it 'returns a successful response' do
      pending 'Post test'
    end
  end
end
