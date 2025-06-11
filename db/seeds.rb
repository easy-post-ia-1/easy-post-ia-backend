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
Rails.logger.debug 'Companies'
# Create Companies first
companies = []
2.times do
  company = Company.create!(
    name: Faker::Company.name
  )
  companies << company
  Rails.logger.debug "Created company: #{company.name} (ID: #{company.id})"
end

Rails.logger.debug '=' * 20
Rails.logger.debug 'Users'
# Create User accounts
users = []
roles = %w[ADMIN EMPLOYER EMPLOYEE]
3.times do |i|
  user_attrs = {
    username: Faker::Internet.unique.username,
    email: "#{Faker::Internet.unique.username}@example.com",
    password: 'Password123',
    password_confirmation: 'Password123',
    role: roles[i],
    company: companies.sample
  }
  Rails.logger.debug "DEBUG: user_attrs before creation: #{user_attrs.inspect}"
  users << User.create!(**user_attrs)
  Rails.logger.debug "Created user: #{users.last.username} (ID: #{users.last.id}) for company: #{users.last.company.name}"
end

# Create Twitter credentials for each company
companies.each do |company|
  Credentials::Twitter.create!(
    company: company,
    api_key: Faker::Alphanumeric.alpha(number: 10),
    api_key_secret: Faker::Alphanumeric.alpha(number: 10),
    access_token: Faker::Alphanumeric.alpha(number: 10),
    access_token_secret: Faker::Alphanumeric.alpha(number: 10)
  )
  Rails.logger.debug "Created Twitter credentials for company: #{company.name}"
end

Rails.logger.debug '=' * 20
Rails.logger.debug 'Teams'
# Create Teams for each company
teams = []
companies.each do |company|
  2.times do
    team = company.teams.create!(name: Faker::Team.name)
    teams << team
    Rails.logger.debug "Created team: #{team.name} for company: #{company.name}"
  end
end

Rails.logger.debug '=' * 20
Rails.logger.debug 'Team Members'
# Create Team Members
team_members = []
teams.each_with_index do |team, index|
  team_member = team.team_members.create!(user_id: users[index % users.length].id, role_id: 1) # Assuming role_id 1 is a valid default
  team_members << team_member
  Rails.logger.debug "Created team member: #{team_member.user.username} for team: #{team.name}"
end

Rails.logger.debug '=' * 20
Rails.logger.debug 'Strategies and Posts'
# Define strategy and post data consistently
strategy_statuses = [0, 1, 2, 3] # pending, in_progress, completed, failed
strategy_descriptions = [
  'Q1 Marketing Campaign',
  'Product Launch Strategy',
  'Social Media Engagement Plan',
  'Brand Awareness Initiative',
  'Customer Retention Program'
]

# Create strategies and posts for each team
teams.each do |team|
  3.times do |i|
    current_team_member = team.team_members.sample || team_members.first # Ensure a team member is always available
    strategy = Strategy.create!(
      company: team.company,
      team_member: current_team_member,
      from_schedule: Faker::Time.forward(days: i + 1, period: :morning).iso8601,
      to_schedule: Faker::Time.forward(days: i + 2, period: :evening).iso8601,
      description: strategy_descriptions.sample,
      status: strategy_statuses.sample
    )
    Rails.logger.debug "Created strategy: #{strategy.description} (ID: #{strategy.id}) for team: #{team.name}"

    # Create posts for each strategy
    5.times do |j|
      Post.create!(
        title: Faker::Lorem.sentence(word_count: 3),
        description: Faker::Lorem.paragraph,
        tags: Faker::Lorem.words(number: 2).join(','),
        image_url: Faker::LoremFlickr.image(size: '400x300', search_terms: ['business']),
        programming_date_to_post: Faker::Time.forward(days: rand(1..30)).iso8601,
        team_member: current_team_member,
        strategy: strategy,
        status: j % 7, # Cycle through all post statuses
        is_published: [true, false].sample
      )
      Rails.logger.debug "  Created post for strategy: #{strategy.id}"
    end
  end
end

# Create sample strategies for the first company
sample_strategies = [
  {
    description: 'Summer Marketing Campaign',
    from_schedule: Time.current + 1.week,
    to_schedule: Time.current + 2.weeks,
    status: 0 # pending
  },
  {
    description: 'Product Launch Strategy',
    from_schedule: Time.current + 2.days,
    to_schedule: Time.current + 1.week,
    status: 1 # in_progress
  },
  {
    description: 'Holiday Special Campaign',
    from_schedule: Time.current - 1.week,
    to_schedule: Time.current,
    status: 2 # completed
  },
  {
    description: 'Failed Campaign Example',
    from_schedule: Time.current - 2.weeks,
    to_schedule: Time.current - 1.week,
    status: 3 # failed
  }
]

sample_strategies.each do |strategy_attrs|
  strategy = Strategy.create!(
    company: companies.first,
    team_member: team_members.first,
    **strategy_attrs
  )

  # Create sample posts for each strategy
  posts = [
    {
      title: 'First post of the campaign',
      description: 'Initial campaign post',
      status: 0, # pending
      strategy: strategy,
      team_member: team_members.first,
      programming_date_to_post: Time.current + 1.day,
      is_published: false,
      tags: 'marketing,campaign'
    },
    {
      title: 'Second post in progress',
      description: 'Campaign update',
      status: 1, # publishing
      strategy: strategy,
      team_member: team_members.first,
      programming_date_to_post: Time.current + 2.days,
      is_published: false,
      tags: 'update,progress'
    },
    {
      title: 'Successfully published post',
      description: 'Campaign milestone',
      status: 2, # published
      strategy: strategy,
      team_member: team_members.first,
      programming_date_to_post: Time.current + 3.days,
      is_published: true,
      tags: 'success,milestone'
    }
  ]

  posts.each do |post_attrs|
    Post.create!(post_attrs)
  end
end

# Create or find test company
begin
  company = Company.find_or_create_by!(name: 'Test Company') do |c|
    puts "Creating new company: #{c.name}"
  end

  # Create or find team for the company
  team = company.teams.find_or_create_by!(name: 'Test Team') do |t|
    puts "Creating new team: #{t.name}"
  end

  # Create a team member for the test team
  test_user = users.first # Use one of the existing users
  test_team_member = team.team_members.find_or_create_by!(user: test_user) do |tm|
    # Assuming role_id is needed, use a default or an appropriate one
    tm.role_id = 1 # Adjust this role_id as per your application's logic
    puts "Creating new team member for #{team.name}: #{test_user.username}"
  end

  # Create or find test strategies if they don't exist
  strategies = [
    {
      description: 'Test Strategy 1',
      status: 0, # pending
      from_schedule: Time.current,
      to_schedule: 1.week.from_now
    },
    {
      description: 'Test Strategy 2',
      status: 1, # in_progress
      from_schedule: Time.current,
      to_schedule: 2.weeks.from_now
    },
    {
      description: 'Test Strategy 3',
      status: 2, # completed
      from_schedule: 1.week.ago,
      to_schedule: Time.current
    }
  ]

  strategies.each do |strategy_attrs|
    strategy = Strategy.find_or_create_by!(
      description: strategy_attrs[:description],
      company: company,
      team_member: test_team_member # Use the newly created test_team_member
    ) do |s|
      s.status = strategy_attrs[:status]
      s.from_schedule = strategy_attrs[:from_schedule]
      s.to_schedule = strategy_attrs[:to_schedule]
      puts "Creating new strategy: #{s.description} with status: #{s.status}"
    end
  end

  puts "\nSeed Summary:"
  puts "Company: #{company.name} (ID: #{company.id})"
  puts "Team: #{team.name} (ID: #{team.id})"
  puts "Team Member: #{test_team_member.user.username} (ID: #{test_team_member.id})"
  puts "Strategies: #{Strategy.where(company: company).count}"
  puts "Strategy IDs: #{Strategy.where(company: company).pluck(:id)}"

rescue ActiveRecord::RecordInvalid => e
  puts "Error creating records: #{e.message}"
  puts "Backtrace: #{e.backtrace[0..5].join("\n")}"
  raise e
end

Rails.logger.debug 'Seeding completed successfully!'
