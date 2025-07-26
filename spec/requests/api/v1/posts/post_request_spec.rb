# frozen_string_literal: true

require 'swagger_helper'

describe 'Posts API' do
  path '/api/v1/posts' do
    get 'List posts for the current user' do
      tags 'Posts'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :page_size, in: :query, type: :integer, required: false

      response '200', 'Posts listed' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 posts: { type: :array, items: { type: :object } },
                 pagination: { '$ref' => '#/components/schemas/Pagination' }
               },
               required: %w[status posts pagination]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        run_test!
      end
      response '401', 'Unauthorized' do
        let(:Authorization) { '' }
        run_test!
      end
    end

    post 'Create a post' do
      tags 'Posts'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :post, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          tags: { type: :string },
          category: { type: :string },
          emoji: { type: :string },
          programming_date_to_post: { type: :string, format: :date_time },
          is_published: { type: :boolean },
          image_url: { type: :string, nullable: true }
        },
        required: %w[title description tags category emoji programming_date_to_post]
      }
      response '201', 'Post created' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 post: { type: :object }
               },
               required: %w[status post]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:post) do
          {
            title: 'Test Post',
            description: 'Test description',
            tags: 'tag1,tag2',
            category: 'Marketing',
            emoji: '🚀',
            programming_date_to_post: Time.now.utc.iso8601,
            is_published: true
          }
        end
        run_test!
      end
      response '422', 'Validation error' do
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:post) { { title: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/posts/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Show a post' do
      tags 'Posts'
      produces 'application/json'
      security [Bearer: []]
      response '200', 'Post found' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 post: { type: :object }
               },
               required: %w[status post]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:post).id }
        run_test!
      end
      response '404', 'Post not found' do
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { 9999 }
        run_test!
      end
      response '401', 'Unauthorized' do
        let(:Authorization) { '' }
        let(:id) { 1 }
        run_test!
      end
    end

    put 'Update a post' do
      tags 'Posts'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :post, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          tags: { type: :string },
          category: { type: :string },
          emoji: { type: :string },
          programming_date_to_post: { type: :string, format: :date_time },
          is_published: { type: :boolean },
          image_url: { type: :string, nullable: true }
        }
      }
      response '200', 'Post updated' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 post: { type: :object }
               },
               required: %w[status post]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:post).id }
        let(:post) { { title: 'Updated Title' } }
        run_test!
      end
      response '404', 'Post not found' do
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { 9999 }
        let(:post) { { title: 'Updated Title' } }
        run_test!
      end
      response '422', 'Validation error' do
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:post).id }
        let(:post) { { title: '' } }
        run_test!
      end
    end

    delete 'Delete a post' do
      tags 'Posts'
      produces 'application/json'
      security [Bearer: []]
      response '200', 'Post deleted' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' }
               },
               required: %w[status]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:post).id }
        run_test!
      end
      response '404', 'Post not found' do
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { 9999 }
        run_test!
      end
    end
  end
end
