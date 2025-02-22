# frozen_string_literal: true

# Sisekiq job to publish a post on a social network
class PublishSocialNetworkPostJob
  include Sidekiq::Worker

  def perform(*args)
    Rails.logger.info 'Start Proccess Publish Post'
    platform = 'twitter'
    case platform
    when 'twitter'
      Api::V1::PublishSocialNetwork::Twitter::PublishHelper.post(args[:post_id])
    when 'tiktok'
      # TikTokHelper.post(description)
    else
      st.update!(status: :failed)
      Rails.logger.error "Unsupported platform: #{platform} - user - #{args[:creator_id]}"
    end

    Rails.logger.info 'Strategy processed successfully.'
  rescue StandardError => e
    Rails.logger.error "Error proce ssing strategy: #{e.message}"
  end
end
