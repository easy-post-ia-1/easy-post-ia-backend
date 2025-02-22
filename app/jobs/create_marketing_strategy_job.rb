# frozen_string_literal: true

require 'sidekiq-cron'

# Create strategy job class
class CreateMarketingStrategyJob < ApplicationJob
  queue_as :default

  def perform(config_post:)
    Rails.logger.info 'Processing strategy...'
    Rails.logger.info "From: #{config_post[:from_schedule]}, To: #{config_post[:to_schedule]}, Description: #{config_post[:description]}"

    st = Strategy.find(config_post[:strategy_id])
    st.update!(status: :in_progress)

    begin
      result = Api::V1::PublishSocialNetwork::Bedrock::CreatePostsIaHelper.build_posts_ia(
        user_prompt: config_post[:description],
        options: {
          strategy_id: st.id,
          creator_id: config_post[:creator_id]
        }
      )

      if result[:status] == :success && result[:posts].present?
        result[:posts].each do |post_id|
          job_name = "PublishSocialNetworkPostJob-#{post_id}-#{Time.now.to_i}"
          res = Sidekiq::Cron::Job.create(
            name: job_name,
            cron: Post.programming_date_to_cron(post_id),
            class: 'PublishSocialNetworkPostJob',
            args: { post_id: post_id, creator_id: config_post[:creator_id] }
          )

          st.update(status: :scheduled)
          return { status: res, message: 'success' }
        end

        { status: res, message: 'Something wrong' }
      end
    rescue StandardError => e
      Rails.logger.error("Error while building posts: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))

      st.update!(status: :failed)
    end
  end
end
