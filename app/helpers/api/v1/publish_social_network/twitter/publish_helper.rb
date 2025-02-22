# frozen_string_literal: true

require 'open-uri'
require 'tempfile'
require 'x'
require 'x/media_uploader'

module Api
  module V1
    module PublishSocialNetwork
      # Post helper
      module Twitter
        # Post helper
        module PublishHelper
          def self.twitter_client
            @twitter_client ||= X::Client.new(
              api_key: ENV.fetch('TWITTER_API_KEY', nil),
              api_key_secret: ENV.fetch('TWITTER_API_KEY_SECRET', nil),
              access_token: ENV.fetch('TWITTER_ACCESS_TOKEN', nil),
              access_token_secret: ENV.fetch('TWITTER_ACCESS_TOKEN_SECRET', nil)
            )
          end

          def self.post(post_id)
            post = Post.find(post_id)
            return if post.blank?

            publish_tweet(post)

            st.update!(status: :completed)
          rescue StandardError => e
            st.update!(status: :failed)
            Rails.logger.error "Twitter post failed: #{e.message}"
          end

          def self.publish_tweet(post)
            Tempfile.create(['media', '.jpg']) do |tempfile|
              tempfile.binmode
              tempfile.write URI.open(post.image_url).read
              tempfile.rewind

              media_category = 'tweet_image'
              media = X::MediaUploader.upload(client: twitter_client, file_path: tempfile.path, media_category:)

              tweet_body = { text: post.description,
                             media: { media_ids: [media['media_id_string']] } }
              tweet = twitter_client.post('tweets', tweet_body.to_json)

              Rails.logger.info "Tweet posted successfully with data: #{tweet['data']['id']}"
            end
          rescue OpenURI::HTTPError => e
            Rails.logger.error "Failed to download the image: #{e.message}"
          rescue X::Error => e
            Rails.logger.error "X API Error: #{e.message}"
          rescue StandardError => e
            Rails.logger.error "An unexpected error occurred: #{e.message}"
          end
        end
      end
    end
  end
end
