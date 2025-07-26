# frozen_string_literal: true

# Sisekiq job to publish a post on a social network
class PublishSocialNetworkPostJob
  include Sidekiq::Worker

  def perform(args)
    Rails.logger.info 'Start Proccess Publish Post'
    Rails.logger.info "ARGS publish post: #{args}" # Log the whole hash

    post_id = args['post_id'] # Extract post_id from args
    unless post_id
      Rails.logger.error "Job arguments do not contain 'post_id'. Args: #{args}"
      return
    end

    post_record = Post.find(post_id)
    st = post_record.strategy # strategy can be nil if post has no strategy

    # Proceed only if strategy is found
    unless st
      Rails.logger.error "No strategy found for Post id #{post_id}. Aborting publish."
      return
    end

    st.update!(status: :in_progress)

    platform = args['platform'] || 'twitter'
    case platform
    when 'twitter'
      Api::V1::PublishSocialNetwork::Twitter::PublishHelper.post(post_id) # Pass post_id
    when 'tiktok'
      # TikTokHelper.post(description)
    else
      st.update!(status: :failed)
      Rails.logger.error "Unsupported platform: #{platform} - Post id #{post_id}"
    end

    # Update to completed if no errors occurred
    st.update!(status: :completed)
    Rails.logger.info 'Strategy processed successfully.'
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Post not found: #{e.message} - Post id #{args['post_id']}"
    # No strategy to update if post itself isn't found
  rescue StandardError => e
    loaded_strategy = defined?(st) ? st : nil
    loaded_strategy&.update!(status: :failed)
    Rails.logger.error "Error processing strategy: #{e.message} - Post id #{args['post_id']}"
  end
end
