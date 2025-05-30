# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
#
require 'faker'

Rails.logger.debug '=' * 20
Rails.logger.debug 'Users'
# Create User accounts
users = []
roles = %w[ADMIN EMPLOYER EMPLOYEE]
3.times do |i|
  users << User.create!(
    username: Faker::Internet.unique.username,
    email: Faker::Internet.unique.email,
    password: 'Password123',
    password_confirmation: 'Password123',
    role: roles[i]
  )
end

Rails.logger.debug '=' * 20
Rails.logger.debug 'Companies'
# Create a Company
company = Company.create!(name: Faker::Company.name)

Rails.logger.debug '=' * 20
Rails.logger.debug 'Teams'
# Create Teams
teams = []
2.times { teams << company.teams.create!(name: Faker::Team.name) }

Rails.logger.debug '=' * 20
Rails.logger.debug 'Team Members'
# Create Team Members
team_members = []
teams.each_with_index do |team, index|
  team_members << team.team_members.create!(user_id: users[index].id, role_id: index + 1)
end

Rails.logger.debug '=' * 20
Rails.logger.debug 'Strategies and Posts'
# Create Strategies with Posts
3.times do |i|
  strategy = Strategy.create!(
    from_schedule: Faker::Time.forward(days: i + 1, period: :morning).iso8601,
    to_schedule: Faker::Time.forward(days: i + 2, period: :evening).iso8601,
    description: Faker::Lorem.sentence,
    status: %i[pending in_progress completed].sample,
    success_response: { message: 'Strategy created successfully' },
    error_response: { message: 'No error' }
  )

  # Create 10 posts per strategy
  10.times do
    Post.create!(
      title: Faker::Lorem.sentence(word_count: 3),
      description: Faker::Lorem.paragraph,
      tags: Faker::Lorem.words(number: 2).join(','),
      image_url: Faker::LoremFlickr.image(size: '400x300', search_terms: ['business']),
      programming_date_to_post: Faker::Time.forward(days: rand(1..30)).iso8601,
      team_member: team_members.sample,
      strategy: strategy
    )
  end
end

Rails.logger.debug 'Seeding completed successfully!'
