# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Posts::Posts' do
  describe 'GET /index' do
    it 'returns http success' do
      get '/api/v1/posts/post/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /show' do
    it 'returns http success' do
      get '/api/v1/posts/post/show'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /create' do
    it 'returns http success' do
      get '/api/v1/posts/post/create'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /update' do
    it 'returns http success' do
      get '/api/v1/posts/post/update'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /destroy' do
    it 'returns http success' do
      get '/api/v1/posts/post/destroy'
      expect(response).to have_http_status(:success)
    end
  end
end
