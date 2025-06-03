require 'swagger_helper' # or 'rails_helper'

RSpec.describe 'Api::V1::StrategiesController', type: :request do
  include ApiHelpers # Make JWT helper available

  # --- Swagger Docs for GET /api/v1/strategies ---
  path '/strategies' do # Corrected path (no /api/v1 prefix)
    get 'Lists strategies for the current user\'s team' do
      tags 'Strategies'
      produces 'application/json'
      security [Bearer: []] # JWT authentication

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
                       description: { type: :string, example: 'My marketing strategy' },
                       status_display: {
                         type: :object,
                         properties: {
                           name: { type: :string, example: 'Pending' },
                           color: { type: :string, example: '#FFD700' },
                           key: { type: :string, example: 'pending' }
                         },
                         required: ['name', 'color', 'key']
                       },
                       from_schedule: { type: :string, format: 'date-time', example: '2023-01-01T00:00:00.000Z' },
                       to_schedule: { type: :string, format: 'date-time', example: '2023-01-31T23:59:59.000Z' },
                       post_ids: { type: :array, items: { type: :integer }, example: [101, 102] }
                     },
                     required: ['id', 'description', 'status_display', 'post_ids']
                   }
                 },
                 pagination: { '$ref' => '#/components/schemas/Pagination' }
               },
               required: ['status', 'strategies', 'pagination']

        let(:user_for_docs) {
          u = create(:user, username: "docuser_#{SecureRandom.hex(3)}", email: "docuser_#{SecureRandom.hex(3)}@example.com")
          co = create(:company, name: "DocCompany_#{SecureRandom.hex(3)}")
          t = create(:team, company: co, name: "DocTeam_#{SecureRandom.hex(3)}")
          create(:team_member, user: u, team: t)
          # Create a strategy for this user for the example to work
          p = create(:post, team_member: u.team_member)
          create(:strategy, posts: [p], description: 'Doc Example Strategy')
          u
        }
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user(user_for_docs)}" }
        run_test!
      end

      response '401', 'Unauthorized' do
        schema '$ref' => '#/components/schemas/StatusUnauthorized'
        let(:Authorization) { "Bearer invalid_token" }
        # This will run the general unauthenticated test below
        run_test!
      end

      response '422', 'User not associated with a team' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusError' },
                 errors: { type: :array, items: { type: :string }, example: ['User is not associated with a team.'] }
               },
               required: ['status', 'errors']

        let(:user_no_team_for_doc) {
          u = create(:user, username: "docuser_no_team_#{SecureRandom.hex(3)}", email: "docuser_no_team_#{SecureRandom.hex(3)}@example.com")
          u.team_member&.destroy
          u
        }
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user(user_no_team_for_doc)}" }
        run_test!
      end
    end
  end

  # --- Existing RSpec test examples ---
  let!(:user) { create(:user) }
  let!(:company) { create(:company) }
  let!(:team) { create(:team, company: company) }
  let!(:team_member) { create(:team_member, user: user, team: team) }

  let!(:other_user) { create(:user, username: "otheruser_#{SecureRandom.hex(4)}", email: "otheruser_#{SecureRandom.hex(4)}@example.com") }
  let!(:other_company) { create(:company, name: "OtherCo") }
  let!(:other_team) { create(:team, company: other_company, name: 'OtherTeam') }
  let!(:other_team_member) { create(:team_member, user: other_user, team: other_team) }


  describe 'GET /api/v1/strategies' do
    context 'when authenticated' do
      context 'and user is associated with a team' do
        let!(:post1_team1) { create(:post, team_member: team_member) }
        let!(:post2_team1) { create(:post, team_member: team_member) }
        # Ensure strategy factory can handle posts association or posts are added after creation
        let!(:strategy1_team1) { create(:strategy, description: 'Strategy 1 Team 1') }
        let!(:strategy2_team1) { create(:strategy, description: 'Strategy 2 Team 1', status: :completed) }

        # Associate posts with strategies
        before do
          strategy1_team1.posts << post1_team1
          strategy2_team1.posts << post2_team1
        end

        # Create a strategy for another team (should not be returned)
        let!(:post_other_team) { create(:post, team_member: other_team_member) }
        let!(:strategy_other_team) { create(:strategy, posts: [post_other_team], description: 'Strategy Other Team') }


        it 'returns status 200 and strategies for the user\'s team with correct data' do
          get '/api/v1/strategies', headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user)}" }

          expect(response).to have_http_status(:ok)
          json_response = JSON.parse(response.body)

          expect(json_response['status']['code']).to eq(200)
          expect(json_response['strategies'].size).to eq(2)
          expect(json_response['strategies'].map{ |s| s['description'] }).to match_array(['Strategy 1 Team 1', 'Strategy 2 Team 1'])

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
          expect(Time.parse(returned_strategy1['from_schedule'])).to be_within(1.second).of(strategy1_team1.from_schedule) if strategy1_team1.from_schedule && returned_strategy1['from_schedule']
          expect(Time.parse(returned_strategy1['to_schedule'])).to be_within(1.second).of(strategy1_team1.to_schedule) if strategy1_team1.to_schedule && returned_strategy1['to_schedule']
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

          get '/api/v1/strategies', params: { page: 1, page_size: 5 }, headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user)}" }
          json_response_page1 = JSON.parse(response.body)
          expect(response).to have_http_status(:ok)
          expect(json_response_page1['strategies'].size).to eq(5)
          expect(json_response_page1['pagination']['page']).to eq(1)
          expect(json_response_page1['pagination']['per_page']).to eq(5)
          expect(json_response_page1['pagination']['count']).to eq(12) # 2 original + 10 new

          get '/api/v1/strategies', params: { page: 3, page_size: 5 }, headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user)}" }
          json_response_page3 = JSON.parse(response.body)
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
          json_response = JSON.parse(response.body)
          expect(json_response['status']['code']).to eq(200)
          expect(json_response['strategies']).to be_empty
          expect(json_response['pagination']['count']).to eq(0)
        end
      end

      context 'and user is not associated with a team' do
        let(:user_no_team) { create(:user, username: "user_no_team_#{SecureRandom.hex(4)}", email: "user_no_team_#{SecureRandom.hex(4)}@example.com") }
        before do
          user_no_team.team_member&.destroy # Ensure no team association
        end

        it 'returns status 422 (unprocessable_entity)' do
          get '/api/v1/strategies', headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user_no_team)}" }
          expect(response).to have_http_status(:unprocessable_entity)
          json_response = JSON.parse(response.body)
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
