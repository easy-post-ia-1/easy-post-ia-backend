# frozen_string_literal: true

require 'swagger_helper' # or 'rails_helper'

RSpec.describe 'Api::V1::StrategiesController' do
  include ApiHelpers # Make JWT helper available

  path '/api/v1/strategies' do
    get 'Lists strategies for the current user\'s team' do
      tags 'Strategies'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :page, in: :query, type: :integer, description: 'Page number for pagination', required: false
      parameter name: :page_size, in: :query, type: :integer, description: 'Number of items per page', required: false

      response '200', 'Successfully retrieved strategies' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 strategies: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       description: { type: :string, example: 'Marketing Strategy Q1' },
                       from_schedule: { type: :string, format: :date_time, example: '2024-01-01T00:00:00Z' },
                       to_schedule: { type: :string, format: :date_time, example: '2024-03-31T23:59:59Z' },
                       status: { type: :string, example: 'active' },
                       posts_count: { type: :integer, example: 5 },
                       posts: {
                         type: :array,
                         items: {
                           type: :object,
                           properties: {
                             id: { type: :integer, example: 1 }
                           }
                         }
                       }
                     }
                   }
                 },
                 pagination: { '$ref' => '#/components/schemas/Pagination' }
               },
               required: %w[status strategies pagination]

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
                 strategy: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     description: { type: :string, example: 'Marketing Strategy Q1' },
                     from_schedule: { type: :string, format: :date_time, example: '2024-01-01T00:00:00Z' },
                     to_schedule: { type: :string, format: :date_time, example: '2024-03-31T23:59:59Z' },
                     status: { type: :string, example: 'active' },
                     posts_count: { type: :integer, example: 5 },
                     posts: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id: { type: :integer, example: 1 }
                         }
                       }
                     }
                   }
                 }
               },
               required: %w[status strategy]

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:strategy).id }
        run_test!
      end

      response '404', 'Strategy not found' do
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

  path '/api/v1/strategy/create' do
    post 'Creates a new marketing strategy' do
      tags 'Strategies'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :strategy, in: :body, schema: {
        type: :object,
        properties: {
          from_schedule: { type: :string, format: :date_time, example: '2024-01-01T00:00:00Z' },
          to_schedule: { type: :string, format: :date_time, example: '2024-03-31T23:59:59Z' },
          description: { type: :string, example: 'Marketing Strategy Q1' }
        },
        required: %w[from_schedule to_schedule description]
      }

      response '201', 'Strategy created successfully' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 strategy: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     status: { type: :string, example: 'active' }
                   }
                 }
               },
               required: %w[status strategy]

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:strategy) do
          {
            from_schedule: '2024-01-01T00:00:00Z',
            to_schedule: '2024-03-31T23:59:59Z',
            description: 'Marketing Strategy Q1'
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
        let(:strategy) { { description: 'Only description provided' } }
        run_test!
      end
    end
  end

  # --- Existing RSpec test examples ---
  let!(:user) { create(:user) }
  let!(:company) { create(:company) }
  let!(:team) { create(:team, company: company) }
  let!(:team_member) { create(:team_member, user: user, team: team) }

  let!(:other_user) do
    create(:user, username: "otheruser_#{SecureRandom.hex(4)}", email: "otheruser_#{SecureRandom.hex(4)}@example.com")
  end
  let!(:other_company) { create(:company, name: 'OtherCo') }
  let!(:other_team) { create(:team, company: other_company, name: 'OtherTeam') }
  let!(:other_team_member) { create(:team_member, user: other_user, team: other_team) }

  describe 'GET /api/v1/strategies' do
    context 'when authenticated' do
      context 'and user is associated with a team' do
        let!(:post1_team1) { create(:post, team_member: team_member) }
        # Create a strategy for another team (should not be returned)
        let!(:post_other_team) { create(:post, team_member: other_team_member) }
        let!(:strategy_other_team) { create(:strategy, posts: [post_other_team], description: 'Strategy Other Team') }
        let!(:post2_team1) { create(:post, team_member: team_member) }
        # Ensure strategy factory can handle posts association or posts are added after creation
        let!(:strategy1_team1) { create(:strategy, description: 'Strategy 1 Team 1') }
        let!(:strategy2_team1) { create(:strategy, description: 'Strategy 2 Team 1', status: :completed) }

        # Associate posts with strategies
        before do
          strategy1_team1.posts << post1_team1
          strategy2_team1.posts << post2_team1
        end

        it 'returns status 200 and strategies for the user\'s team with correct data' do
          get '/api/v1/strategies', headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user)}" }

          expect(response).to have_http_status(:ok)
          json_response = response.parsed_body

          expect(json_response['status']['code']).to eq(200)
          expect(json_response['strategies'].size).to eq(2)
          expect(json_response['strategies'].map do |s|
            s['description']
          end).to contain_exactly('Strategy 1 Team 1', 'Strategy 2 Team 1')

          # Check structure of one strategy
          # Find strategy1_team1 in the response (order might vary)
          returned_strategy1 = json_response['strategies'].find { |s| s['id'] == strategy1_team1.id }
          expect(returned_strategy1).not_to be_nil

          expect(returned_strategy1['id']).to eq(strategy1_team1.id)
          expect(returned_strategy1['description']).to eq(strategy1_team1.description)
          # status_display.key should be the string version of the enum symbol
          expect(returned_strategy1['status_display']['key']).to eq(strategy1_team1.status.to_s)
          expect(returned_strategy1['status_display']['name']).to be_present
          expect(returned_strategy1['status_display']['color']).to be_present
          # Compare Time objects to handle minor ISO 8601 formatting differences (Z vs +00:00)
          if strategy1_team1.from_schedule && returned_strategy1['from_schedule']
            expect(Time.zone.parse(returned_strategy1['from_schedule'])).to be_within(1.second).of(strategy1_team1.from_schedule)
          end
          if strategy1_team1.to_schedule && returned_strategy1['to_schedule']
            expect(Time.zone.parse(returned_strategy1['to_schedule'])).to be_within(1.second).of(strategy1_team1.to_schedule)
          end
          expect(returned_strategy1['post_ids']).to include(post1_team1.id)

          # Check pagination structure
          expect(json_response['pagination']).to include('page', 'per_page', 'pages', 'count')
          expect(json_response['pagination']['count']).to eq(2)
        end

        it 'handles pagination correctly' do
          # Create more strategies for pagination test (e.g., 12 total for page_size 10)
          # The two existing strategies (strategy1_team1, strategy2_team1) are already associated with user's team.
          10.times do |i|
            p = create(:post, team_member: team_member) # Post associated with the correct team_member
            create(:strategy, posts: [p], description: "Paginated Strategy #{i}")
          end

          get '/api/v1/strategies', params: { page: 1, page_size: 5 },
                                    headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user)}" }
          json_response_page1 = response.parsed_body
          expect(response).to have_http_status(:ok)
          expect(json_response_page1['strategies'].size).to eq(5)
          expect(json_response_page1['pagination']['page']).to eq(1)
          expect(json_response_page1['pagination']['per_page']).to eq(5)
          expect(json_response_page1['pagination']['count']).to eq(12) # 2 original + 10 new

          get '/api/v1/strategies', params: { page: 3, page_size: 5 },
                                    headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user)}" }
          json_response_page3 = response.parsed_body
          expect(response).to have_http_status(:ok)
          expect(json_response_page3['strategies'].size).to eq(2) # Remaining 2
          expect(json_response_page3['pagination']['page']).to eq(3)
        end
      end

      context 'and user is associated with a team that has no strategies' do
        it 'returns status 200 and an empty strategies array' do
          # In this context, no strategies are explicitly created for 'user' or their team.
          get '/api/v1/strategies', headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user)}" }
          expect(response).to have_http_status(:ok)
          json_response = response.parsed_body
          expect(json_response['status']['code']).to eq(200)
          expect(json_response['strategies']).to be_empty
          expect(json_response['pagination']['count']).to eq(0)
        end
      end

      context 'and user is not associated with a team' do
        let(:user_no_team) do
          create(:user, username: "user_no_team_#{SecureRandom.hex(4)}",
                        email: "user_no_team_#{SecureRandom.hex(4)}@example.com")
        end

        before do
          user_no_team.team_member&.destroy # Ensure no team association
        end

        it 'returns status 422 (unprocessable_entity)' do
          get '/api/v1/strategies',
              headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user_no_team)}" }
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = response.parsed_body
          expect(json_response['status']['code']).to eq(422)
          expect(json_response['errors']).to include('User is not associated with a team.')
        end
      end
    end

    context 'when not authenticated' do
      it 'returns status 401 (unauthorized)' do
        get '/api/v1/strategies'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
