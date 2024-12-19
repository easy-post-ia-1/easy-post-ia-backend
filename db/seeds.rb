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
Rails.logger.debug '=' * 20
Rails.logger.debug 'Users'
# Create User accounts
user1 = User.create!(
  username: 'test_user1',
  email: 'test_user1@example.com',
  password: 'Password123',
  password_confirmation: 'Password123',
  role: 'ADMIN'
)

user2 = User.create!(
  username: 'test_user2',
  email: 'test_user2@example.com',
  password: 'Password123',
  password_confirmation: 'Password123',
  role: 'EMPLOYER'
)

User.create!(
  username: 'test_user3',
  email: 'test_user3@example.com',
  password: 'Password123',
  password_confirmation: 'Password123',
  role: 'EMPLOYEE'
)

Rails.logger.debug '=' * 20
Rails.logger.debug 'Companies'
# Create a Company
company = Company.create!(name: 'Tech Innovators Inc.')

Rails.logger.debug '=' * 20
Rails.logger.debug 'Teams'

# Create Teams
team1 = company.teams.create!(name: 'Empanada Team')
team2 = company.teams.create!(name: 'Mondongo Team')

Rails.logger.debug '=' * 20
Rails.logger.debug 'Teams Members'
# Create Team Members
team_member1 = team1.team_members.create!(user_id: user1.id, role_id: 1)
team_member2 = team2.team_members.create!(user_id: user2.id, role_id: 2)

Rails.logger.debug '=' * 20

# Create 3 strategies
3.times do |i|
  strategy = Strategy.create!(
    from_schedule: (DateTime.now.utc + (i + 1).days).iso8601,
    to_schedule: (DateTime.now.utc + (i + 2).days).iso8601,
    description: "Strategy Description #{i + 1}",
    status: %i[pending in_progress completed].sample,
    success_response: { message: 'Strategy created successfully' },
    error_response: { message: 'No error' }
  )

  # Create 10 posts for each strategy
  10.times do |j|
    Post.create!(
      title: "Post Title #{(i * 10) + j + 1}",
      description: "Description for Post #{(i * 10) + j + 1}.",
      tags: (j.even? ? 'rails,api' : 'marketing,startups'),
      image_url: "https://placehold.co/400?text=Post+#{(i * 10) + j + 1}",
      programming_date_to_post: (DateTime.now.utc + ((i * 10) + j + 1).days).iso8601,
      team_member: j.even? ? team_member1 : team_member2,
      strategy:
    )
  end
end
