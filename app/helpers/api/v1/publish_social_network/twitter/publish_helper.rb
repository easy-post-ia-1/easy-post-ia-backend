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
          def self.twitter_client(api_key:, api_key_secret:, access_token:, access_token_secret:)
            X::Client.new(
              api_key: api_key,
              api_key_secret: api_key_secret,
              access_token: access_token,
              access_token_secret: access_token_secret
            )
          end

          def self.post(post_id)
            post_record = Post.find_by(id: post_id) # Renamed to avoid conflict
            return unless post_record

            strategy = post_record.strategy # Define strategy for use throughout
            strategy.update!(status: :in_progress_posting)

            company = post_record.team&.company
            unless company
              strategy.update!(status: :failed)
              Rails.logger.error "Twitter post failed: Post id #{post_id} has no associated company."
              return
            end

            twitter_credentials = company.credentials_twitter
            unless twitter_credentials&.has_credentials?
              strategy.update!(status: :failed) # Or a more specific status like :missing_credentials
              Rails.logger.error "Twitter post failed: Company #{company.id} missing Twitter credentials for Post id #{post_id}."
              return
            end

            # Initialize client with credentials from DB
            client = twitter_client(
              api_key: twitter_credentials.api_key,
              api_key_secret: twitter_credentials.api_key_secret,
              access_token: twitter_credentials.access_token,
              access_token_secret: twitter_credentials.access_token_secret
            )

            publish_tweet(post_record, client, strategy) # Pass client and strategy
          rescue ActiveRecord::RecordNotFound
            Rails.logger.error "Twitter post failed: Post id #{post_id} not found."
            # No strategy to update if post not found. If strategy needs update, it must be found differently.
          rescue StandardError => e
            # Ensure strategy is defined or handle nil; strategy might be nil if Post.find_by failed before strategy was set
            defined?(strategy) && strategy&.update!(status: :failed)
            Rails.logger.error "Twitter post failed: #{e.message} - Post id #{post_id}"
          end

          def self.publish_tweet(post, client, strategy) # Added client and strategy as params
            Tempfile.create(['media', '.jpg']) do |tempfile|
              tempfile.binmode
              tempfile.write URI.open(post.image_url).read
              tempfile.rewind

              media_category = 'tweet_image'
              # Pass the initialized client here
              media = X::MediaUploader.upload(client: client, file_path: tempfile.path, media_category: media_category)

              tweet_body = { text: post.description,
                             media: { media_ids: [media['media_id_string']] } }
              # Use the initialized client here
              tweet = client.post('tweets', tweet_body.to_json)

              strategy.update!(status: :posted) # Use passed strategy
              Rails.logger.info "Tweet posted successfully with data: #{tweet['data']['id']}"
            end
          rescue OpenURI::HTTPError => e
            strategy.update!(status: :failed) # Use passed strategy
            Rails.logger.error "Failed to download the image: #{e.message}"
          rescue X::Error => e
            strategy.update!(status: :failed_social_network) # Use passed strategy
            Rails.logger.error "X API Error: #{e.message}"
          rescue StandardError => e
            strategy.update!(status: :failed_system) # Use passed strategy
            Rails.logger.error "An unexpected error occurred: #{e.message}"
          end
        end
      end
    end
  end
end
