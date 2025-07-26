# frozen_string_literal: true

require 'sidekiq-cron'

# Create strategy job class
class CreateMarketingStrategyJob < ApplicationJob
  queue_as :default

  def perform(config_post)
    Rails.logger.info 'Processing strategy...'
    Rails.logger.info "From: #{config_post[:from_schedule]}, To: #{config_post[:to_schedule]}, Description: #{config_post[:description]}"

    # Find the strategy by the provided strategy_id (created by the controller)
    st = Strategy.find_by(id: config_post[:strategy_id])

    unless st
      Rails.logger.error("Strategy not found with ID: #{config_post[:strategy_id]}")
      return { status: :error, message: 'Strategy not found', posts: [], strategy_id: nil }
    end

    st.update!(status: :in_progress)

    begin
      result = Api::V1::PublishSocialNetwork::Bedrock::CreatePostsIaHelper.build_posts_ia(
        user_prompt: config_post[:description],
        options: {
          strategy_id: st&.id,
          creator_id: config_post[:creator_id]
        }
      )

      res_posts = []
      if result[:status] == :success && result[:posts].present?
        result[:posts].each do |post_id|
          # TODO: 1. All job is work and test with my twitter.
          # 2. Do models and terraform dev.
          # 3. upload github and get in the server and upload this, verify work.
          # 4. Generate application.
          # 5. Do the sena videos.
          # 6. Do technical manuals.

          job_name = "PublishSocialNetworkPostJob-#{post_id}-#{Time.now.to_i}"
          schedule_post = Sidekiq::Cron::Job.new(
            name: job_name,
            cron: Post.programming_date_to_cron(post_id),
            class: 'PublishSocialNetworkPostJob',
            args: { post_id: post_id, creator_id: config_post[:creator_id] }
          )

          next unless schedule_post.valid?

          schedule_post.save
          res_posts.push(schedule_post)
        end

        st.update!(status: :completed)
        { status: :success, message: 'Posts scheduled', posts: res_posts, strategy_id: st&.id }
      else
        st.update!(status: :failed)
        { status: :error, message: 'No posts created', posts: [], strategy_id: st&.id }
      end
    rescue StandardError => e
      Rails.logger.error("Error while building posts: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))

      st.update!(status: :failed)
      { status: :error, message: 'An error occurred', posts: [], strategy_id: st&.id }
    end
  end
end
