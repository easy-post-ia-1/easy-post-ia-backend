# frozen_string_literal: true

# Sisekiq job to publish a post on a social network
class PublishSocialNetworkPostJob
  include Sidekiq::Worker

  def perform(args) # Reverted to args
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

    st.update!(status: :in_progress_config)

    platform = 'twitter' # Assuming platform might be dynamic in future
    case platform
    when 'twitter'
      Api::V1::PublishSocialNetwork::Twitter::PublishHelper.post(post_id) # Pass post_id
    when 'tiktok'
      # TikTokHelper.post(description)
    else
      st.update!(status: :failed)
      Rails.logger.error "Unsupported platform: #{platform} - Post id #{post_id}"
    end

    Rails.logger.info 'Strategy processed successfully.'
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Post not found: #{e.message} - Post id #{args['post_id']}" # Use args['post_id'] for logging consistency
    # No strategy to update if post itself isn't found
  rescue StandardError => e
    # Log with post_id from args for context
    # Ensure st is loaded before trying to update it, or it might be nil if Post.find failed earlier than RecordNotFound
    loaded_strategy = defined?(st) ? st : nil
    loaded_strategy&.update!(status: :failed)
    Rails.logger.error "Error processing strategy: #{e.message} - Post id #{args['post_id']}"
  end
end
