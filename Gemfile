# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.2', '>= 7.2.1'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1', '>= 3.1.11'

# Pagination
gem 'pagy'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Test swagger
gem 'rswag-api'
gem 'rswag-ui'

# Auth and serializer
gem 'devise', '~> 4.9', '>= 4.9.4'
gem 'devise-jwt', '~> 0.12.1'
gem 'jsonapi-serializer', '~> 2.2'

# Authorization and roles
gem 'cancancan', '~> 3.6', '>= 3.6.1'
gem 'rolify', '~> 6.0', '>= 6.0.1'

gem 'rack-cors' # After configure all project without views

# # Store multiple changes
gem 'logidze', '~> 1.1'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'annotate' # Schema in classes
  gem 'debug', platforms: %i[mri windows]
  gem 'discard', '~> 1.2' # Soft delete fields.
  gem 'factory_bot_rails' # Automatic factories
  gem 'faker' # Emulate data
  gem 'rspec-rails' # Tests
  gem 'rswag-specs'

  # Rubocop test
  gem 'rubocop', require: false
  gem 'rubocop-capybara', '~> 2.21', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', '~> 2.26', '>= 2.26.1', require: false
  gem 'rubocop-rspec', '~> 3.0', '>= 3.0.5', require: false
  gem 'rubocop-rspec_rails', '~> 2.30', require: false

  gem 'shoulda-matchers' # Simplify test to be oneline
  gem 'simplecov', require: false # Coverage to the test
  gem 'yard' # Annotations to class definitions
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Security analysis
  gem 'brakeman', require: false

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem 'spring'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'database_cleaner-redis'
  gem 'database_cleaner-sequel'
  gem 'selenium-webdriver'
  gem 'simplecov-lcov', require: false
end
