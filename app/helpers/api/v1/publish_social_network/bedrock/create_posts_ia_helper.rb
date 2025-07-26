# frozen_string_literal: true

require 'aws-sdk-bedrock'
require 'aws-sdk-bedrockruntime'
require 'ostruct'

# TODO: Simplify and testing all
module Api
  module V1
    module PublishSocialNetwork
      # Post helper
      module Bedrock
        # Post helper for creating posts using Bedrock
        module CreatePostsIaHelper
          include ::ArtifactsHelper
          def self.bedrock_client
            @bedrock_client ||= Aws::BedrockRuntime::Client.new(
              region: ENV['AWS_REGION'] || 'us-east-1',
              access_key_id: ENV.fetch('AWS_ACCESS_KEY_ID', nil),
              secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY', nil)
            )
          end

          def self.build_posts_ia(user_prompt:, options: {})
            prompt_template = Api::V1::PublishSocialNetwork::Bedrock::Templates::CreateDefaultTemplateHelper::MarketingHelper.generate_marketing_strategy_template(user_strategy: 'I need strategy about cars')
            prompt = "#{prompt_template}#{user_prompt}"
            res = generate_text(prompt)

            post_ids = []
            return { status: :failed, posts: post_ids, error: 'Post dont generated', res: } if res[:posts].blank?

            strategy = Strategy.find(options[:strategy_id])
            team_member = User.find(options[:creator_id]).team_member
            res[:posts].each do |post_data|
              post = Post.new(
                title: post_data['title'],
                description: post_data['description'],
                programming_date_to_post: post_data['programming_date_to_post'],
                tags: post_data['tags'].join(', '),
                category: post_data['category'] || 'Marketing',
                emoji: post_data['emoji'] || '🚀',
                team_member: team_member,
                strategy: strategy
              )

              s3_url = generate_image(post_data['image_prompt'], { post_id: post_data['id'] })
              post.image_url = s3_url[:data] if s3_url[:data].present?
              post.save

              if post.persisted?
                post_ids << post.id
                Rails.logger.info "Post '#{post.title}' created successfully!"
              else
                Rails.logger.error "Failed to create post: #{post.errors.full_messages.join(', ')}"
              end
            end

            { status: :success, posts: post_ids }
          end

          def self.generate_image(prompt = '', options = {})
            body = {
              text_prompts: [
                {
                  text: prompt,
                  weight: 1
                }
              ],
              cfg_scale: options[:cfg_scale] || 8,
              seed: options[:seed] || 42,
              steps: options[:steps] || 50,
              width: options[:width] || 512,
              height: options[:height] || 512
            }

            # response = bedrock_client.invoke_model(
            #   model_id: 'stability.stable-diffusion-xl-v1',
            #   content_type: 'application/json',
            #   accept: 'application/json',
            #   body: body.to_json
            # )
            #
            # body = JSON.parse(response.body.string)
            # img_base64 = body['artifacts'][0]['base64']
            # s3_url = ArtifactsHelper.upload_base64_to_s3(img_base64,
            #                                              "post-id-#{options[:post_id]}_img-#{SecureRandom.uuid}.jpg")
            s3_url = 'https://easy-post-ia-backend-post-images.s3.us-east-2.amazonaws.com/post-id-_img-4c24c058-1798-43dd-a7e4-8880b89e340e.jpg'
            Rails.logger.info("Generated image: #{s3_url}") if s3_url.present?
            { status: body['results'], data: s3_url }
          rescue Aws::Bedrock::Errors::ServiceError => e
            Rails.logger.error("Failed to generate image: #{e.message}")
            { error: e.message }
          end

          def self.generate_text(_prompt, _options = {})
            # body = { prompt: prompt, temperature: 0.7, top_p: 1 }
            # response = bedrock_client.invoke_model(
            #   model_id: 'meta.llama3-70b-instruct-v1:0',
            #   content_type: 'application/json',
            #   accept: 'application/json',
            #   body: body.to_json
            # )
            #
            # generation = JSON.parse(response.body.string)['generation'].match(/\[.*\]/m).to_s
            # body = JSON.parse(generation)
            body = example_body_text

            Rails.logger.info("Generated text: #{body}")
            { status: body.present? ? :success : :failed, posts: body }
          rescue Aws::Bedrock::Errors::ServiceError => e
            Rails.logger.error("Failed to generate text: #{e.message}")
            { error: e.message }
          end

          def self.example_body_text
            [{ 'title' => 'Boost Your Business!',
               'description' =>
    'Stay ahead of the competition with our expert marketing strategies. Learn how to increase your online visibility and drive sales.',
               'image_prompt' =>
    'A graphic with a rocket ship blasting off, surrounded by business-related icons.',
               'tags' => ['#marketing', '#business', '#growth'],
               'category' => 'Marketing',
               'emoji' => '🚀',
               'programming_date_to_post' => '2025-03-11T10:00:00+00:00' },
             { 'title' => 'Spring into Action!',
               'description' =>
               'As the seasons change, refresh your marketing approach. Get tips on how to create engaging content and attract new customers.',
               'image_prompt' =>
               'A spring-themed graphic with a calendar, flowers, and a briefcase.',
               'tags' => ['#spring', '#marketing', '#newbeginnings'],
               'category' => 'News',
               'emoji' => '📰',
               'programming_date_to_post' => '2025-03-18T14:00:00+00:00' }]
          end
        end
      end
    end
  end
end
