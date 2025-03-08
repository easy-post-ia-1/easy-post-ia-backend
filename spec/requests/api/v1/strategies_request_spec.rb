# frozen_string_literal: true

# :nocov:
require 'swagger_helper'

describe 'Strategies API' do
  path '/api/v1/strategies' do
    post 'Creates a marketing strategy' do
      tags 'Strategies'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :strategy, in: :body, schema: {
        type: :object,
        properties: {
          from_schedule: { type: :string, format: :date_time, example: '2025-03-01T10:00:00Z' },
          to_schedule: { type: :string, format: :date_time, example: '2025-03-10T18:00:00Z' },
          description: { type: :string, example: 'New campaign strategy for social media' }
        },
        required: %w[from_schedule to_schedule description]
      }

      response '200', 'Strategy created successfully' do
        schema type: :object,
               properties: {
                 status: { type: :string, example: 'ok' },
                 message: { type: :string, example: 'ok' },
                 data: {
                   type: :object,
                   properties: {
                     idProccess: { type: :integer, example: 1 }
                   }
                 }
               }

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:strategy) do
          {
            from_schedule: '2025-03-01T10:00:00Z',
            to_schedule: '2025-03-10T18:00:00Z',
            description: 'New campaign strategy for social media'
          }
        end
        xit
      end

      response '422', 'Missing required parameters' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Missing parameters: from_schedule, to_schedule' }
               }

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:strategy) { { description: 'Only description provided' } }
        xit
      end
    end
  end
end
# :nocov:
