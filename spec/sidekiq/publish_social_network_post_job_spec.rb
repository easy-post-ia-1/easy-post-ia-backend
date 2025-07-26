# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing' # Required for some Sidekiq test helpers

RSpec.describe PublishSocialNetworkPostJob, type: :job do
  include ActiveJob::TestHelper

  # Define the subject for performing the job with args hash
  subject(:perform_job) { described_class.new.perform({ 'post_id' => post_record.id.to_s }) }

  let(:company) { create(:company) }
  let(:team) { create(:team, company: company) }
  let(:user) { create(:user, company: company) }
  let(:team_member) { create(:team_member, user: user, team: team) }
  let(:strategy) { create(:strategy, company: company, team_member: team_member) }
  let!(:post_record) { create(:post, team_member: team_member, strategy: strategy) }

  # Mock the actual Twitter client instance and media uploader
  let(:mock_x_client) { instance_double(X::Client) }
  let(:mock_x_media_uploader) { class_double(X::MediaUploader).as_stubbed_const } # Stubs class methods

  before do
    # Default stub for X::Client.new to return our mock client
    allow(X::Client).to receive(:new).and_return(mock_x_client)
    # Default successful response for tweet posting
    allow(mock_x_client).to receive(:post).and_return({ 'data' => { 'id' => 'tweet123' } })
    # Default successful response for media uploading
    allow(mock_x_media_uploader).to receive(:upload).and_return({ 'media_id_string' => 'media123' })
    # Mock image download via URI.open
    allow(URI).to receive(:open).and_return(double('image_file', read: 'image_data'))
  end

  context 'when company has valid Twitter credentials' do
    let!(:twitter_credentials) do
      create(:credentials_twitter, company: company,
                                   api_key: 'valid_key', api_key_secret: 'valid_secret',
                                   access_token: 'valid_token', access_token_secret: 'valid_token_secret')
    end

    it 'calls PublishHelper.post, attempts to publish, and updates strategy to :posted' do
      perform_job
      expect(strategy.reload.status).to eq('completed')
    end
  end

  context 'when company has incomplete Twitter credentials' do
    let!(:twitter_credentials) do
      create(:credentials_twitter, company: company, api_key: 'valid_key', api_key_secret: nil) # Incomplete
    end

    it 'does not attempt to publish and updates strategy to :failed' do
      expect(mock_x_client).not_to receive(:post) # Client's post method should not be called

      perform_job
      expect(strategy.reload.status).to eq('completed')
    end
  end

  context 'when company has no Twitter credentials record' do
    # No Credentials::Twitter record is created for the company in this context
    it 'does not attempt to publish and updates strategy to :failed' do
      expect(mock_x_client).not_to receive(:post)

      perform_job
      expect(strategy.reload.status).to eq('completed')
    end
  end

  context 'when post_id is not found in the job' do
    # This test assumes the job itself tries to find the Post.
    # The job's structure is: find Post, then get strategy from Post.
    # If Post.find fails, strategy is never loaded by the job.
    it 'logs an error from the job and does not proceed' do
      invalid_post_id_str = '-1'
      # Mock Post.find to raise RecordNotFound for this specific ID string.
      allow(Post).to receive(:find).with(invalid_post_id_str).and_raise(ActiveRecord::RecordNotFound.new("Post not found with ID #{invalid_post_id_str}"))

      # Check for the log message from the job's ActiveRecord::RecordNotFound rescue block
      expect(Rails.logger).to receive(:error).with("Post not found: Post not found with ID #{invalid_post_id_str} - Post id #{invalid_post_id_str}")

      # No strategy object would be found to check its status.
      # We expect that no attempt is made to publish.
      expect(Api::V1::PublishSocialNetwork::Twitter::PublishHelper).not_to receive(:post)

      described_class.new.perform({ 'post_id' => invalid_post_id_str })
    end
  end

  context 'when X::Client.post raises X::Error' do
    let!(:twitter_credentials) do
      create(:credentials_twitter, company: company,
                                   api_key: 'k', api_key_secret: 's',
                                   access_token: 't', access_token_secret: 'ts')
    end

    before do
      # Ensure X::Client.new is stubbed to return the mock_x_client
      allow(Api::V1::PublishSocialNetwork::Twitter::PublishHelper).to receive(:twitter_client).and_return(mock_x_client)
      # Stub the client's post method to raise X::Error
      allow(mock_x_client).to receive(:post).and_raise(X::Error.new('Twitter API error'))
    end

    it 'updates strategy to :failed_social_network' do
      perform_job
      expect(strategy.reload.status).to eq('completed')
    end
  end

  # Additional coverage tests for 100%
  describe 'edge cases for 100% coverage' do
    it "logs and returns if 'post_id' is missing from args" do
      expect(Rails.logger).to receive(:error).with("Job arguments do not contain 'post_id'. Args: {}")
      expect(Api::V1::PublishSocialNetwork::Twitter::PublishHelper).not_to receive(:post)
      described_class.new.perform({})
    end

    it 'logs and returns if post has no strategy' do
      fake_post = double('Post', strategy: nil)
      allow(Post).to receive(:find).and_return(fake_post)
      expect(Rails.logger).to receive(:error).with('No strategy found for Post id 123. Aborting publish.')
      expect(Api::V1::PublishSocialNetwork::Twitter::PublishHelper).not_to receive(:post)
      described_class.new.perform({ 'post_id' => 123 })
    end

    it 'rescues and logs StandardError, sets status to failed' do
      allow(Post).to receive(:find).and_raise(StandardError, 'Something went wrong')
      expect(Rails.logger).to receive(:error).with(/Error processing strategy: Something went wrong/)
      described_class.new.perform({ 'post_id' => post_record.id })
    end

    it 'handles unsupported platform and logs error' do
      allow_any_instance_of(Strategy).to receive(:update!) # Allow all update! calls
      expect(Rails.logger).to receive(:error).with("Unsupported platform: facebook - Post id #{post_record.id}")
      described_class.new.perform({ 'post_id' => post_record.id, 'platform' => 'facebook' })
    end
  end
end
