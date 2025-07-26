# frozen_string_literal: true

require 'swagger_helper'

describe 'Dashboard API' do
  path '/api/v1/dashboard/employer_metrics' do
    get 'Get employer metrics for the current user' do
      tags 'Dashboard'
      produces 'application/json'
      security [Bearer: []]
      response '200', 'Metrics retrieved' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 totalStrategies: { type: :integer },
                 totalPosts: { type: :integer },
                 publishedPosts: { type: :integer },
                 failedPosts: { type: :integer },
                 pendingPosts: { type: :integer },
                 postsPerStrategy: { type: :array, items: { type: :object } }
               },
               required: %w[status totalStrategies totalPosts publishedPosts failedPosts pendingPosts postsPerStrategy]
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        run_test!
      end
      response '403', 'Forbidden' do
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