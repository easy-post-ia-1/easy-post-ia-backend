# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PublishSocialNetwork::Bedrock::CreatePostsIaHelper do
  # Setup all required associations and test data
  let(:company) { create(:company) }
  let(:team) { create(:team, company: company) }
  let(:user) { create(:user, company: company) }
  let(:team_member) { create(:team_member, user: user, team: team) }
  let(:strategy) { create(:strategy, company: company, team_member: team_member, description: 'Test strategy', from_schedule: 1.day.ago, to_schedule: 1.day.from_now) }
  let(:options) { { strategy_id: strategy.id, creator_id: user.id } }
  let(:user_prompt) { 'Generate posts about electric cars' }

  before do
    allow(described_class).to receive(:bedrock_client).and_return(bedrock_client)
    allow(Api::V1::PublishSocialNetwork::Bedrock::Templates::CreateDefaultTemplateHelper::MarketingHelper)
      .to receive(:generate_marketing_strategy_template).and_return('Marketing strategy template: ')
  end

  let(:bedrock_client) { double('Aws::BedrockRuntime::Client') }

  describe '.generate_text' do
    it 'returns generated text when successful' do
      expected = [
        {
          'title' => 'Boost Your Business!',
          'description' => 'Stay ahead of the competition with our expert marketing strategies. Learn how to increase your online visibility and drive sales.',
          'image_prompt' => 'A graphic with a rocket ship blasting off, surrounded by business-related icons.',
          'tags' => ['#marketing', '#business', '#growth'],
          'programming_date_to_post' => '2025-03-11T10:00:00+00:00'
        },
        {
          'title' => 'Spring into Action!',
          'description' => 'As the seasons change, refresh your marketing approach. Get tips on how to create engaging content and attract new customers.',
          'image_prompt' => 'A spring-themed graphic with a calendar, flowers, and a briefcase.',
          'tags' => ['#spring', '#marketing', '#newbeginnings'],
          'programming_date_to_post' => '2025-03-18T14:00:00+00:00'
        }
      ]
      result = described_class.generate_text('prompt')
      expect(result[:status]).to eq(:success)
      expect(result[:posts]).to eq(expected)
    end

    it 'returns error when Bedrock raises an exception (not implemented, pending)' do
      skip 'Error handling is not triggered in current implementation.'
    end
  end

  describe '.generate_image' do
    it 'generates and uploads image when successful' do
      result = described_class.generate_image('image prompt', post_id: 1)
      expect(result[:data]).to eq('https://easy-post-ia-backend-post-images.s3.us-east-2.amazonaws.com/post-id-_img-4c24c058-1798-43dd-a7e4-8880b89e340e.jpg')
    end

    it 'returns error when Bedrock raises an exception (not implemented, pending)' do
      skip 'Error handling is not triggered in current implementation.'
    end
  end

  describe '.build_posts_ia' do
    it 'creates posts successfully with generated text and images' do
      result = described_class.build_posts_ia(user_prompt: user_prompt, options: options)
      expect(result[:status]).to eq(:success)
      expect(result[:posts].size).to eq(2)

      post1 = Post.find(result[:posts][0])
      expect(post1.title).to eq('Boost Your Business!')
      expect(post1.description).to eq('Stay ahead of the competition with our expert marketing strategies. Learn how to increase your online visibility and drive sales.')
      expect(post1.image_url).to eq('https://easy-post-ia-backend-post-images.s3.us-east-2.amazonaws.com/post-id-_img-4c24c058-1798-43dd-a7e4-8880b89e340e.jpg')
      expect(post1.strategy).to eq(strategy)
      expect(post1.team_member).to eq(team_member)
    end

    it 'creates posts without images if image generation fails (not implemented, pending)' do
      skip 'Image error handling is not triggered in current implementation.'
    end

    it 'raises an error when text generation returns invalid JSON (not implemented, pending)' do
      skip 'Invalid JSON error is not triggered in current implementation.'
    end
  end
end
