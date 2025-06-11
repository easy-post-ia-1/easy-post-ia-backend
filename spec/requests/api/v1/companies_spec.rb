require 'swagger_helper' # Ensures Rswag DSL is available

RSpec.describe 'Api::V1::CompaniesController', type: :request do
  include ApiHelpers

  let!(:user) { create(:user) }
  let!(:company) { create(:company) }
  let!(:team) { create(:team, company: company) }
  let!(:team_member) { create(:team_member, user: user, team: team) }

  # --- Swagger Docs for GET /api/v1/me/company_social_status ---
  path '/api/v1/me/company_social_status' do
    get 'Retrieves social network credential status for the current user\'s company' do
      tags 'Companies', 'User Profile'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'Social network status retrieved' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 social_networks: {
                   type: :object,
                   properties: {
                     twitter: {
                       type: :object,
                       properties: {
                         has_credentials: { type: :boolean, example: true }
                       },
                       required: ['has_credentials']
                     }
                   },
                   required: ['twitter']
                 }
               },
               required: ['status', 'social_networks']

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

      response '404', 'User not associated with a company' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusError' },
                 errors: { type: :array, items: { type: :string } }
               }
        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        run_test!
      end
    end
  end

  # --- Swagger Docs for GET /api/v1/companies/:id ---
  path '/api/v1/companies/{id}' do
    parameter name: :id, in: :path, type: :integer, required: true

    get 'Retrieves a specific company by ID' do
      tags 'Companies'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'Company details retrieved' do
        schema type: :object,
               properties: {
                 status: { '$ref' => '#/components/schemas/StatusSuccess' },
                 company: {
                   type: :object,
                   properties: {
                     id: { type: :integer, example: 1 },
                     name: { type: :string, example: 'Acme Corp' }
                   },
                   required: ['id', 'name']
                 }
               },
               required: ['status', 'company']

        let(:Authorization) { "Bearer #{generate_jwt_token_for_user}" }
        let(:id) { create(:company).id }
        run_test!
      end

      response '404', 'Company not found' do
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

  # --- Existing RSpec test examples ---
  # These will run independently of Rswag's `run_test!` unless `run_test!` is placed
  # inside each `it` block or structured to replace them.
  # For this integration, `run_test!` is used for the "happy path" Swagger examples.
  # The other RSpec examples provide more detailed context-specific tests.

  describe 'GET /api/v1/me/company_social_status (RSpec examples)' do
    context 'when authenticated' do
      context 'and user is associated with a company' do
        # Case: complete Twitter credentials (covered by Rswag response '200' run_test!)
        # We can add more specific assertions here if needed, beyond what run_test! does by default.
        context 'and company has complete Twitter credentials' do
          let!(:twitter_credentials) { create(:credentials_twitter, company: company, api_key: 'key', api_key_secret: 'secret', access_token: 'token', access_token_secret: 'token_secret') }
          it 'returns status 200 and has_credentials: true' do
            get '/api/v1/me/company_social_status', headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user)}" }
            expect(response).to have_http_status(:ok)
            json_response = JSON.parse(response.body)
            expect(json_response['status']['code']).to eq(200)
            expect(json_response['social_networks']['twitter']['has_credentials']).to be_truthy
          end
        end

        context 'and company has incomplete Twitter credentials' do
          let!(:twitter_credentials) { create(:credentials_twitter, company: company, api_key: 'key', api_key_secret: nil) }
          it 'returns status 200 and has_credentials: false' do
            get '/api/v1/me/company_social_status', headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user)}" }
            expect(response).to have_http_status(:ok)
            json_response = JSON.parse(response.body)
            expect(json_response['status']['code']).to eq(200)
            expect(json_response['social_networks']['twitter']['has_credentials']).to be_falsey
          end
        end

        context 'and company has no Twitter credentials record' do
          it 'returns status 200 and has_credentials: false' do
            get '/api/v1/me/company_social_status', headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user)}" }
            expect(response).to have_http_status(:ok)
            json_response = JSON.parse(response.body)
            expect(json_response['status']['code']).to eq(200)
            expect(json_response['social_networks']['twitter']['has_credentials']).to be_falsey
          end
        end
      end

      context 'and user is not associated with a company' do
        let(:user_no_company) { create(:user, username: "user_no_company_#{SecureRandom.hex(4)}", email: "user_no_company_#{SecureRandom.hex(4)}@example.com") }
        before { user_no_company.team_member&.destroy }
        it 'returns status 404 (not_found) as per controller logic (actually 422)' do
          get '/api/v1/me/company_social_status', headers: { 'Authorization' => "Bearer #{generate_jwt_token_for_user(user_no_company)}" }
          expect(response).to have_http_status(:not_found) # Controller renders :not_found
          json_response = JSON.parse(response.body)
          # The controller's error_response uses code 422 by default in its structure.
          # The HTTP status code is :not_found (404). The internal JSON code is a separate matter.
          expect(json_response['status']['code']).to eq(422)
          expect(json_response['errors']).to include('User is not associated with a company.')
        end
      end
    end

    context 'when not authenticated' do
      it 'returns status 401 (unauthorized)' do
        get '/api/v1/me/company_social_status'
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/companies/:id (RSpec examples)' do
    # Case: company exists (covered by Rswag response '200' run_test!)
    # Additional specific assertions can go here if needed.
    context 'when company exists' do
        it 'returns status 200 and the company data' do
          get "/api/v1/companies/#{company.id}"
          expect(response).to have_http_status(:ok)
          # assertions are in the run_test! block for the swagger definition
        end
      end

    # Case: company does not exist (covered by Rswag response '404' run_test!)
    context 'when company does not exist' do
        it 'returns status 404 (not_found) as per controller logic (actually 422 in json)' do
          get "/api/v1/companies/#{company.id + 999}"
          expect(response).to have_http_status(:not_found) # Controller renders :not_found
          # assertions are in the run_test! block for the swagger definition
        end
      end
  end
end
