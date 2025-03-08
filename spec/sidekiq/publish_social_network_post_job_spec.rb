require 'rails_helper'

# TODO: Change sidekiq folders and use jobs folder
RSpec.describe CreateMarketingStrategyJob, type: :job do
  include ActiveJob::TestHelper

  let(:strategy) { create(:strategy, status: :pending) }
  let(:creator) { create(:user) }
  let(:config_post) do
    {
      strategy_id: strategy.id,
      creator_id: creator.id,
      from_schedule: '2023-10-01',
      to_schedule: '2023-10-31',
      description: 'Generate posts for Q4 marketing campaign'
    }
  end

  describe '#perform' do
    context 'when the job executes successfully' do
      before do
        allow(Api::V1::PublishSocialNetwork::Bedrock::CreatePostsIaHelper).to receive(:build_posts_ia)
          .and_return({ status: :success, posts: [1, 2, 3] })
      end

      it 'updates the strategy status to :scheduled and schedules posts' do
        expect(Sidekiq::Cron::Job).to receive(:create).exactly(3).times.and_return(true)

        result = described_class.perform_now(config_post: config_post)

        expect(strategy.reload.status).to eq('scheduled')
        expect(result[:status]).to eq(:success)
        expect(result[:message]).to eq('Posts scheduled')
        expect(result[:posts].count).to eq(3)
      end
    end

    context 'when no posts are created' do
      before do
        allow(Api::V1::PublishSocialNetwork::Bedrock::CreatePostsIaHelper).to receive(:build_posts_ia)
          .and_return({ status: :success, posts: [] })
      end

      it 'updates the strategy status to :failed and returns an error message' do
        result = described_class.perform_now(config_post: config_post)

        expect(strategy.reload.status).to eq('failed')
        expect(result[:status]).to eq(:error)
        expect(result[:message]).to eq('No posts created')
        expect(result[:posts]).to be_empty
      end
    end

    context 'when an error occurs during post creation' do
      before do
        allow(Api::V1::PublishSocialNetwork::Bedrock::CreatePostsIaHelper).to receive(:build_posts_ia)
          .and_raise(StandardError.new('Something went wrong'))
      end

      it 'logs the error, updates the strategy status to :failed, and returns an error message' do
        expect(Rails.logger).to receive(:error).at_least(:once)

        result = described_class.perform_now(config_post: config_post)

        expect(strategy.reload.status).to eq('failed')
        expect(result[:status]).to eq(:error)
        expect(result[:message]).to eq('An error occurred')
        expect(result[:posts]).to be_empty
      end
    end
  end
end
