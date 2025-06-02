# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::PublishSocialNetwork::Bedrock::CreatePostsIaHelper do
  # Setup doubles and test data
  let(:bedrock_client) { double('Aws::BedrockRuntime::Client') }
  let(:strategy) { create(:strategy) }
  let(:user) { create(:user, team_member: create(:team_member)) }
  let(:options) { { strategy_id: strategy.id, creator_id: user.id } }
  let(:user_prompt) { 'Generate posts about electric cars' }

  # Common setup for all tests
  before do
    allow(described_class).to receive(:bedrock_client).and_return(bedrock_client)
    allow(Api::V1::PublishSocialNetwork::Bedrock::Templates::CreateDefaultTemplateHelper::MarketingHelper)
      .to receive(:generate_marketing_strategy_template).and_return('Marketing strategy template: ')
  end

  ### Tests for generate_text method
  describe '.generate_text' do
    it 'returns generated text when successful' do
      prompt = 'Marketing strategy template: Generate posts about electric cars'
      response_body = { 'generation' => '[ {"title": "Post 1", "description": "Desc 1", "image_prompt": "img1"} ]' }.to_json
      response = double('response', body: double('body', string: response_body))
      allow(bedrock_client).to receive(:invoke_model).and_return(response)

      result = described_class.generate_text(prompt)
      expect(result[:status]).to be :success
      expect(result[:posts]).to eq([{ 'title' => 'Post 1', 'description' => 'Desc 1', 'image_prompt' => 'img1' }])
    end

    it 'returns error when Bedrock raises an exception' do
      allow(bedrock_client).to receive(:invoke_model)
        .and_raise(Aws::Bedrock::Errors::ServiceError.new('context', 'Bedrock error'))
      result = described_class.generate_text('prompt')
      expect(result[:error]).to eq('Bedrock error')
    end
  end

  ### Tests for generate_image method
  describe '.generate_image' do
    it 'generates and uploads image when successful' do
      prompt = 'image prompt'
      options = { post_id: 1 }
      response_body = { 'artifacts' => [{ 'base64' => 'base64data' }] }.to_json
      response = double('response', body: double('body', string: response_body))
      allow(bedrock_client).to receive(:invoke_model).and_return(response)
      allow(ArtifactsHelper).to receive(:upload_base64_to_s3)
        .with('base64data', anything).and_return('https://s3.url/image.jpg')

      result = described_class.generate_image(prompt, options)
      expect(result[:data]).to eq('https://s3.url/image.jpg')
    end

    it 'returns error when Bedrock raises an exception' do
      allow(bedrock_client).to receive(:invoke_model)
        .and_raise(Aws::Bedrock::Errors::ServiceError.new('context', 'Bedrock error'))
      result = described_class.generate_image('prompt', {})
      expect(result[:error]).to eq('Bedrock error')
    end
  end

  ### Tests for build_posts_ia method
  describe '.build_posts_ia' do
    it 'creates posts successfully with generated text and images' do
      post_data = [
        {
          'id' => 1,
          'title' => 'Post 1',
          'description' => 'Desc 1',
          'programming_date_to_post' => '2023-01-01',
          'tags' => ['tag1'],
          'image_prompt' => 'img1'
        },
        {
          'id' => 2,
          'title' => 'Post 2',
          'description' => 'Desc 2',
          'programming_date_to_post' => '2023-01-02',
          'tags' => ['tag2'],
          'image_prompt' => 'img2'
        }
      ]
      allow(described_class).to receive(:generate_text).and_return({ status: true, posts: post_data })
      allow(described_class).to receive(:generate_image)
        .and_return({ data: 'https://s3.url/image1.jpg' }, { data: 'https://s3.url/image2.jpg' })

      result = described_class.build_posts_ia(user_prompt: user_prompt, options: options)
      expect(result[:status]).to eq(:success)
      expect(result[:posts].size).to eq(2)

      post1 = Post.find(result[:posts][0])
      expect(post1.title).to eq('Post 1')
      expect(post1.description).to eq('Desc 1')
      expect(post1.image_url).to eq('https://s3.url/image1.jpg')
      expect(post1.strategy).to eq(strategy)
      expect(post1.team_member).to eq(user.team_member)
    end

    it 'creates posts without images if image generation fails' do
      post_data = [
        {
          'id' => 1,
          'title' => 'Post 1',
          'description' => 'Desc 1',
          'programming_date_to_post' => '2023-01-01',
          'tags' => ['tag1'],
          'image_prompt' => 'img1'
        }
      ]
      allow(described_class).to receive(:generate_text).and_return({ status: true, posts: post_data })
      allow(described_class).to receive(:generate_image).and_return({ error: 'Image generation failed' })

      result = described_class.build_posts_ia(user_prompt: user_prompt, options: options)
      expect(result[:status]).to eq(:success)
      expect(result[:posts].size).to eq(1)

      post = Post.find(result[:posts][0])
      expect(post.title).to eq('Post 1')
      expect(post.image_url).to be_nil
    end

    it 'raises an error when text generation returns invalid JSON' do
      allow(bedrock_client).to receive(:invoke_model)
        .and_return(double('response', body: double('body', string: '{ "generation": "invalid json" }')))
      expect { described_class.build_posts_ia(user_prompt: user_prompt, options: options) }
        .to raise_error(JSON::ParserError)
    end
  end
end
