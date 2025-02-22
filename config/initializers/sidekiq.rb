# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-cron'

# Load Sidekiq-Cron jobs from the cron YAML file
schedule_file = 'config/schedule.yml'

Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file) if File.exist?(schedule_file) && Sidekiq.server?

Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{ENV.fetch('REDIS_HOST', nil)}:#{ENV.fetch('REDIS_PORT', nil)}/1" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{ENV.fetch('REDIS_HOST', nil)}:#{ENV.fetch('REDIS_PORT', nil)}/1" }
end
