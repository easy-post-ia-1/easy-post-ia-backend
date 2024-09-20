# frozen_string_literal: true

# Load dependencies
RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-rspec_rails'
  task.requires << 'rubocop-capybara'
  task.requires << 'rubocop-rails'
  task.requires << 'rubocop-rspec'
  task.requires << 'rubocop-factory_bot'
end
