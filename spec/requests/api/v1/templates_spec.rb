# frozen_string_literal: true

require 'swagger_helper'

describe 'Templates API' do
  path '/api/v1/templates' do
    get 'List templates for the current user' do
      tags 'Templates'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :page_size, in: :query, type: :integer, required: false
      parameter name: :category, in: :query, type: :string, required: false
      parameter name: :title, in: :query, type: :string, required: false
      parameter name: :template_type, in: :query, type: :string, required: false
      response '200', 'Templates listed' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 templates: { type: :array, items: { type: :object } },
                 pagination: { '$ref' => '#/components/schemas/Pagination' }
               },
               required: %w[status templates pagination]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        run_test!
      end
      response '401', 'Unauthorized' do
        let(:Authorization) { '' }
        run_test!
      end
    end
    post 'Create a template' do
      tags 'Templates'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :template, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          image_url: { type: :string, nullable: true },
          tags: { type: :string },
          category: { type: :string },
          emoji: { type: :string }
        },
        required: %w[title description category emoji]
      }
      response '201', 'Template created' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 template: { type: :object }
               },
               required: %w[status template]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:template) do
          {
            title: 'Test Template',
            description: 'Test description',
            tags: 'tag1,tag2',
            category: 'Marketing',
            emoji: '🚀',
            image_url: nil
          }
        end
        run_test!
      end
      response '422', 'Validation error' do
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:template) { { title: '' } }
        run_test!
      end
    end
  end
  path '/api/v1/templates/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true
    get 'Show a template' do
      tags 'Templates'
      produces 'application/json'
      security [Bearer: []]
      response '200', 'Template found' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 template: { type: :object }
               },
               required: %w[status template]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:template).id }
        run_test!
      end
      response '404', 'Template not found' do
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
    put 'Update a template' do
      tags 'Templates'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :template, in: :body, schema: {
        type: :object,
        properties: {
          title: { type: :string },
          description: { type: :string },
          image_url: { type: :string, nullable: true },
          tags: { type: :string },
          category: { type: :string },
          emoji: { type: :string }
        }
      }
      response '200', 'Template updated' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 template: { type: :object }
               },
               required: %w[status template]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:template).id }
        let(:template) { { title: 'Updated Title' } }
        run_test!
      end
      response '404', 'Template not found' do
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { 9999 }
        let(:template) { { title: 'Updated Title' } }
        run_test!
      end
      response '422', 'Validation error' do
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:template).id }
        let(:template) { { title: '' } }
        run_test!
      end
    end
    delete 'Delete a template' do
      tags 'Templates'
      produces 'application/json'
      security [Bearer: []]
      response '200', 'Template deleted' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' }
               },
               required: %w[status]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:template).id }
        run_test!
      end
      response '404', 'Template not found' do
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { 9999 }
        run_test!
      end
    end
  end
  path '/api/v1/templates/categories' do
    get 'List template categories' do
      tags 'Templates'
      produces 'application/json'
      security [Bearer: []]
      response '200', 'Categories listed' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 categories: { type: :array, items: { type: :object } }
               },
               required: %w[status categories]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        run_test!
      end
      response '401', 'Unauthorized' do
        let(:Authorization) { '' }
        run_test!
      end
    end
  end
end 