# frozen_string_literal: true

require 'swagger_helper'

describe 'Strategies API' do
  path '/api/v1/strategies' do
    get 'Lists strategies for the current user\'s team' do
      tags 'Strategies'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :page_size, in: :query, type: :integer, required: false
      response '200', 'Successfully retrieved strategies' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 strategies: { type: :array, items: { type: :object } },
                 pagination: { '$ref' => '#/components/schemas/Pagination' }
               },
               required: %w[status strategies pagination]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:page) { 1 }
        let(:page_size) { 2 }
        run_test!
      end
      response '401', 'Unauthorized' do
        let(:Authorization) { '' }
        run_test!
      end
    end
    post 'Creates a marketing strategy' do
      tags 'Strategies'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :strategy, in: :body, schema: {
        type: :object,
        properties: {
          from_schedule: { type: :string, format: :date_time, example: '2025-01-01T09:00:00Z' },
          to_schedule: { type: :string, format: :date_time, example: '2025-01-31T18:00:00Z' },
          description: { type: :string, example: 'Q1 Social Media Campaign' }
        },
        required: %w[from_schedule to_schedule description]
      }
      response '201', 'Strategy created successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 strategy: { type: :object }
               },
               required: %w[status strategy]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:strategy) do
          {
            from_schedule: '2025-01-01T09:00:00Z',
            to_schedule: '2025-01-31T18:00:00Z',
            description: 'Q1 Social Media Campaign'
          }
        end
        run_test!
      end
      response '422', 'Missing required parameters' do
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:strategy) { { description: 'Only description provided' } }
        run_test!
      end
    end
  end
  path '/api/v1/strategies/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true
    get 'Retrieves a specific strategy' do
      tags 'Strategies'
      produces 'application/json'
      security [Bearer: []]
      response '200', 'Strategy retrieved successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 strategy: { type: :object }
               },
               required: %w[status strategy]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:strategy).id }
        run_test!
      end
      response '404', 'Strategy not found' do
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { 9999 }
        run_test!
      end
    end
  end
  path '/api/v1/strategies/{strategy_id}/posts' do
    parameter name: :strategy_id, in: :path, type: :integer, required: true

    get 'List posts for a specific strategy' do
      tags 'Strategy Posts'
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
        let(:strategy_id) { create(:strategy).id }
        run_test!
      end
      response '401', 'Unauthorized' do
        let(:Authorization) { '' }
        let(:strategy_id) { 1 }
        run_test!
      end
    end

    post 'Create a post for a specific strategy' do
      tags 'Strategy Posts'
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
        let(:strategy_id) { create(:strategy).id }
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
        let(:strategy_id) { create(:strategy).id }
        let(:post) { { title: '' } }
        run_test!
      end
    end
  end
end
