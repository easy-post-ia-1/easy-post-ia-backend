# frozen_string_literal: true

require 'rubocop/rake_task'

# Load dependencies
RuboCop::RakeTask.new :development do |task|
  task.requires << 'rubocop-rspec_rails'
  task.requires << 'rubocop-capybara'
  task.requires << 'rubocop-rails'
  task.requires << 'rubocop-rspec'
  task.requires << 'rubocop-factory_bot'
end
