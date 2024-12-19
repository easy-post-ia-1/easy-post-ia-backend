# frozen_string_literal: true

# Create strategy job class
class CreateMarketingStrategyJob < ApplicationJob
  queue_as :default

  # Accepts parameters needed for processing the strategy
  def perform(from_schedule, to_schedule, description)
    # Example: Log the received data (you can replace this with actual processing logic)
    Rails.logger.info 'Processing strategy...'
    Rails.logger.info "From: #{from_schedule}, To: #{to_schedule}, Description: #{description}"

    Strategy.create!(
      from_schedule:,
      to_schedule:,
      description:,
      status: :in_progress
    )
    # Create different job to build the post

    Rails.logger.info 'Strategy processed successfully.'
  rescue StandardError => e
    Rails.logger.error "Error processing strategy: #{e.message}"
  end
end
