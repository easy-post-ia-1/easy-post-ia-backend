# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CreateMarketingStrategyJob, type: :job do
  let(:strategy) { create(:strategy, status: :pending) }
  let(:config_post) do
    {
      strategy_id: strategy.id,
      creator_id: 1,
      description: 'Generate marketing content',
      from_schedule: '2025-02-25',
      to_schedule: '2025-02-26'
    }
  end

  before do
    allow(Api::V1::PublishSocialNetwork::Bedrock::CreatePostsIaHelper)
      .to receive(:build_posts_ia)
      .and_return({ status: :success, posts: [1001, 1002] })

    allow(Post).to receive(:programming_date_to_cron).and_return('* * * * *')
    allow(Sidekiq::Cron::Job).to receive(:create).and_return(true)
  end

  describe '#perform' do
    it 'logs the process start and details' do
      expect(Rails.logger).to receive(:info).with('Processing strategy...')
      expect(Rails.logger).to receive(:info).with(
        "From: #{config_post[:from_schedule]}, To: #{config_post[:to_schedule]}, Description: #{config_post[:description]}"
      )

      described_class.new.perform(config_post: config_post)
    end

    it 'updates strategy status correctly' do
      expect { described_class.new.perform(config_post: config_post) }
        .to change { strategy.reload.status }.from('pending').to('scheduled')
    end

    it 'calls the AI API to build posts' do
      described_class.new.perform(config_post: config_post)

      expect(Api::V1::PublishSocialNetwork::Bedrock::CreatePostsIaHelper)
        .to have_received(:build_posts_ia)
        .with(user_prompt: config_post[:description],
              options: { strategy_id: strategy.id, creator_id: config_post[:creator_id] })
    end

    it 'creates a Sidekiq cron job for each post' do
      described_class.new.perform(config_post: config_post)
      expect(Sidekiq::Cron::Job).to have_received(:create).twice
    end

    context 'when an error occurs' do
      before do
        allow(Api::V1::PublishSocialNetwork::Bedrock::CreatePostsIaHelper)
          .to receive(:build_posts_ia).and_raise(StandardError, 'API Failure')
      end

      it 'logs the error and updates strategy to failed' do
        expect(Rails.logger).to receive(:error).with(a_string_matching(/Error while building posts: API Failure/))
        expect(Rails.logger).to receive(:error) # Para capturar la traza del error

        expect { described_class.new.perform(config_post: config_post) }
          .to change { strategy.reload.status }.to('failed')
      end

      it 'returns an error when no posts are created' do
        allow(Api::V1::PublishSocialNetwork::Bedrock::CreatePostsIaHelper)
          .to receive(:build_posts_ia)
          .and_return({ status: :success, posts: [] }) # Simulamos que la API no genera posts

        result = described_class.new.perform(config_post: config_post)

        expect(result).to eq({ status: :error, message: 'No posts created', posts: [] })
        expect(strategy.reload.status).to eq('failed')
      end
    end
  end
end
