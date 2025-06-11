# frozen_string_literal: true

# :nocov:
require 'swagger_helper'

describe 'Posts API', type: :request do
  path '/api/v1/posts' do
    get 'Retrieves all posts' do
      tags 'Posts'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :page, in: :query, type: :integer, description: 'Page number for pagination', required: false
      parameter name: :page_size, in: :query, type: :integer, description: 'Number of items per page', required: false
      parameter name: :from_date, in: :query, type: :string, format: :date_time, description: 'Filter posts from this date', required: false
      parameter name: :to_date, in: :query, type: :string, format: :date_time, description: 'Filter posts until this date', required: false

      response '200', 'Posts retrieved successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 posts: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       title: { type: :string, example: 'Sample Post' },
                       description: { type: :string, example: 'This is a sample post description' },
                       tags: { type: :string, example: 'example,post' },
                       programming_date_to_post: { type: :string, format: :date_time, example: '2024-11-26T00:00:00Z' },
                       team_member_id: { type: :integer, example: 1 }
                     }
                   }
                 },
                 pagination: { '$ref' => '#/components/schemas/Pagination' }
               },
               required: ['status', 'posts', 'pagination']

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        run_test!
      end

      response '401', 'Unauthorized' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusUnauthorized' }
               }
        let(:Authorization) { '' }
        run_test!
      end
    end

    post 'Creates a new post' do
      tags 'Posts'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :post, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'Sample Post' },
          description: { type: :string, example: 'This is a sample post description' },
          tags: { type: :string, example: 'example,post' },
          programming_date_to_post: { type: :string, format: :date_time, example: '2024-11-26T00:00:00Z' },
          team_member_id: { type: :integer, example: 1 }
        },
        required: ['title', 'description', 'tags', 'programming_date_to_post', 'team_member_id']
      }

      response '201', 'Post created successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 post: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     title: { type: :string, example: 'Sample Post' },
                     description: { type: :string, example: 'This is a sample post description' },
                     tags: { type: :string, example: 'example,post' },
                     programming_date_to_post: { type: :string, format: :date_time, example: '2024-11-26T00:00:00Z' },
                     team_member_id: { type: :integer, example: 1 }
                   }
                 }
               },
               required: ['status', 'post']

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:post) do
          {
            title: 'Sample Post',
            description: 'This is a sample post description',
            tags: 'example,post',
            programming_date_to_post: '2024-11-26T00:00:00Z',
            team_member_id: 1
          }
        end
        run_test!
      end

      response '422', 'Validation error' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusError' },
                 errors: { type: :array, items: { type: :string } }
               }
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:post) { { title: '' } }
        run_test!
      end
    end
  end

  path '/api/v1/posts/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Retrieves a specific post' do
      tags 'Posts'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'Post retrieved successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 post: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     title: { type: :string, example: 'Sample Post' },
                     description: { type: :string, example: 'This is a sample post description' },
                     tags: { type: :string, example: 'example,post' },
                     programming_date_to_post: { type: :string, format: :date_time, example: '2024-11-26T00:00:00Z' },
                     team_member_id: { type: :integer, example: 1 }
                   }
                 }
               },
               required: ['status', 'post']

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:post).id }
        run_test!
      end

      response '404', 'Post not found' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusError' },
                 errors: { type: :array, items: { type: :string } }
               }
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { 999 }
        run_test!
      end
    end

    put 'Updates a post' do
      tags 'Posts'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :post, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string, example: 'Updated Post' },
          description: { type: :string, example: 'This is an updated post description' },
          tags: { type: :string, example: 'updated,post' },
          programming_date_to_post: { type: :string, format: :date_time, example: '2024-11-26T00:00:00Z' },
          team_member_id: { type: :integer, example: 1 }
        }
      }

      response '200', 'Post updated successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 post: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     title: { type: :string, example: 'Updated Post' },
                     description: { type: :string, example: 'This is an updated post description' },
                     tags: { type: :string, example: 'updated,post' },
                     programming_date_to_post: { type: :string, format: :date_time, example: '2024-11-26T00:00:00Z' },
                     team_member_id: { type: :integer, example: 1 }
                   }
                 }
               },
               required: ['status', 'post']

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:post).id }
        let(:post) do
          {
            title: 'Updated Post',
            description: 'This is an updated post description',
            tags: 'updated,post',
            programming_date_to_post: '2024-11-26T00:00:00Z',
            team_member_id: 1
          }
        end
        run_test!
      end

      response '422', 'Validation error' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusError' },
                 errors: { type: :array, items: { type: :string } }
               }
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:post).id }
        let(:post) { { title: '' } }
        run_test!
      end
    end

    delete 'Deletes a post' do
      tags 'Posts'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'Post deleted successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' }
               }
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:post).id }
        run_test!
      end

      response '404', 'Post not found' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusError' },
                 errors: { type: :array, items: { type: :string } }
               }
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { 999 }
        run_test!
      end
    end
  end
end
# :nocov:
