# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-cron'

# Load Sidekiq-Cron jobs from the cron YAML file
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
end

schedule_file = 'config/schedule.yml'
if File.exist?(schedule_file) && Sidekiq.server?
  schedule_config = YAML.safe_load_file(schedule_file) || {}
  Sidekiq::Cron::Job.load_from_hash(schedule_config) if schedule_config.is_a?(Hash)
end
