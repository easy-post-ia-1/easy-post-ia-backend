# frozen_string_literal: true

# :nocov:
require 'swagger_helper'

describe 'Posts API', type: :request do
  path '/api/v1/posts' do
    get 'Retrieves all posts' do
      tags 'Posts'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'Posts retrieved successfully' do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 200 },
                     message: { type: :string, example: 'Posts retrieved successfully' }
                   }
                 },
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
                 }
               }

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        xit
      end

      response '401', 'Unauthorized' do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 401 },
                     message: { type: :string, example: 'Unauthorized' }
                   }
                 }
               }

        let(:Authorization) { '' }
        xit
      end
    end

    post 'Creates a post' do
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
        required: %w[title description programming_date_to_post team_member_id]
      }

      response '201', 'Post created successfully' do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 201 },
                     message: { type: :string, example: 'Post created successfully' }
                   }
                 },
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
               }

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:post) do
          { title: 'Sample Post', description: 'This is a sample post description', tags: 'example,post',
            programming_date_to_post: '2024-11-26T00:00:00Z', team_member_id: 1 }
        end
        xit
      end

      response '422', 'Invalid request' do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 422 },
                     message: { type: :string, example: 'Invalid request' }
                   }
                 },
                 errors: { type: :array, items: { type: :string, example: "Title can't be blank" } }
               }

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:post) { { title: '' } }
        xit
      end
    end
  end

  path '/api/v1/posts/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true, description: 'Post ID'

    get 'Retrieves a post' do
      tags 'Posts'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'Post retrieved successfully' do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 200 },
                     message: { type: :string, example: 'Post retrieved successfully' }
                   }
                 },
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
               }

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { 1 }
        xit
      end
    end

    put 'Updates a post' do
      tags 'Posts'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'Post updated successfully' do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 200 },
                     message: { type: :string, example: 'Post updated successfully' }
                   }
                 },
                 post: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     title: { type: :string, example: 'Updated Post' }
                   }
                 }
               }

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { 1 }
        let(:post) { { title: 'Updated Post' } }
        xit
      end
    end

    delete 'Deletes a post' do
      tags 'Posts'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'Post deleted successfully' do
        schema type: :object,
               properties: {
                 status: {
                   type: :object,
                   properties: {
                     code: { type: :integer, example: 200 },
                     message: { type: :string, example: 'Post deleted successfully' }
                   }
                 }
               }

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { 1 }
        xit
      end
    end
  end
end
# :nocov:
