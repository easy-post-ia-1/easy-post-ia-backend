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
2.times do |_i|
  company = Company.create!(
    name: Faker::Company.name,
    code: "COMP#{SecureRandom.alphanumeric(8).upcase}"
  )
  companies << company
  Rails.logger.debug { "Created company: #{company.name} (ID: #{company.id}, Code: #{company.code})" }
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
    password_confirmation: 'Password123'
  }
  Rails.logger.debug { "DEBUG: user_attrs before creation: #{user_attrs.inspect}" }
  user = User.create!(**user_attrs)
  # Assign role with Rolify
  user.add_role(roles[i].downcase.to_sym)
  users << user
  Rails.logger.debug do
    "Created user: #{user.username} (ID: #{user.id}) with role: #{user.roles.pluck(:name).join(', ')}"
  end
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
  Rails.logger.debug { "Created Twitter credentials for company: #{company.name}" }
end

Rails.logger.debug '=' * 20
Rails.logger.debug 'Teams'
# Create Teams for each company
teams = []
companies.each do |company|
  2.times do |_i|
    team = company.teams.create!(name: Faker::Team.name, code: "TEAM#{SecureRandom.alphanumeric(8).upcase}")
    teams << team
    Rails.logger.debug { "Created team: #{team.name} (Code: #{team.code}) for company: #{company.name}" }
  end
end

Rails.logger.debug '=' * 20
Rails.logger.debug 'Team Members'
# Create Team Members for each user (assign each user to a random team)
team_members = []
users.each do |user|
  team = teams.sample
  team_member = TeamMember.create!(user: user, team: team, role_id: 1)
  team_members << team_member
  Rails.logger.debug { "Created team member: #{user.username} in team: #{team.name}" }
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
    Rails.logger.debug { "Created strategy: #{strategy.description} (ID: #{strategy.id}) for team: #{team.name}" }

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
        is_published: [true, false].sample,
        emoji: '🚀',
        category: 'General'
      )
      Rails.logger.debug { "  Created post for strategy: #{strategy.id}" }
    end
  end
end

# Create sample strategies for the first company
sample_strategies = [
  {
    description: 'Summer Marketing Campaign',
    from_schedule: 1.week.from_now,
    to_schedule: 2.weeks.from_now,
    status: 0 # pending
  },
  {
    description: 'Product Launch Strategy',
    from_schedule: 2.days.from_now,
    to_schedule: 1.week.from_now,
    status: 1 # in_progress
  },
  {
    description: 'Holiday Special Campaign',
    from_schedule: 1.week.ago,
    to_schedule: Time.current,
    status: 2 # completed
  },
  {
    description: 'Failed Campaign Example',
    from_schedule: 2.weeks.ago,
    to_schedule: 1.week.ago,
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
      programming_date_to_post: 1.day.from_now,
      is_published: false,
      tags: 'marketing,campaign',
      category: 'Marketing',
      emoji: '🚀'
    },
    {
      title: 'Second post in progress',
      description: 'Campaign update',
      status: 1, # publishing
      strategy: strategy,
      team_member: team_members.first,
      programming_date_to_post: 2.days.from_now,
      is_published: false,
      tags: 'update,progress',
      category: 'News',
      emoji: '📰'
    },
    {
      title: 'Successfully published post',
      description: 'Campaign milestone',
      status: 2, # published
      strategy: strategy,
      team_member: team_members.first,
      programming_date_to_post: 3.days.from_now,
      is_published: true,
      tags: 'success,milestone',
      category: 'Success',
      emoji: '🏆'
    }
  ]

  posts.each do |post_attrs|
    Post.create!(post_attrs)
  end
end


Rails.logger.debug '=' * 20
Rails.logger.debug 'Templates'
# Create default templates for each company
companies.each do |company|
  default_templates = [
    {
      title: 'Product Announcement',
      description: 'Announce a new product or feature to your audience',
      category: 'Marketing',
      emoji: '🚀',
      tags: 'product,announcement,launch',
      is_default: true
    },
    {
      title: 'Company Update',
      description: 'Share important company news and updates',
      category: 'News',
      emoji: '📰',
      tags: 'company,update,news',
      is_default: true
    },
    {
      title: 'Event Promotion',
      description: 'Promote an upcoming event or webinar',
      category: 'Events',
      emoji: '🎉',
      tags: 'event,promotion,webinar',
      is_default: true
    },
    {
      title: 'Customer Success Story',
      description: 'Share a customer success story or testimonial',
      category: 'Success',
      emoji: '🏆',
      tags: 'customer,success,testimonial',
      is_default: true
    },
    {
      title: 'Industry Insights',
      description: 'Share valuable insights about your industry',
      category: 'Insights',
      emoji: '💡',
      tags: 'industry,insights,thought-leadership',
      is_default: true
    },
    {
      title: 'Team Introduction',
      description: 'Introduce a new team member or highlight existing ones',
      category: 'Team',
      emoji: '👥',
      tags: 'team,introduction,people',
      is_default: true
    },
    {
      title: 'Behind the Scenes',
      description: 'Show the human side of your company',
      category: 'Culture',
      emoji: '📸',
      tags: 'culture,behind-scenes,team',
      is_default: true
    },
    {
      title: 'Educational Content',
      description: 'Share educational content or tips with your audience',
      category: 'Education',
      emoji: '📚',
      tags: 'education,tips,how-to',
      is_default: true
    }
  ]

  default_templates.each do |template_attrs|
    Template.create!(
      company: company,
      **template_attrs
    )
    Rails.logger.debug { "Created default template: #{template_attrs[:title]} for company: #{company.name}" }
  end

  # Create team-specific templates for each team
  company.teams.each_with_index do |team, team_index|
    team_templates = [
      {
        title: "Team #{team_index + 1} Meeting Announcement",
        description: 'Announce an upcoming team meeting or event',
        category: 'Team',
        emoji: '👥',
        tags: 'team,meeting,announcement',
        is_default: false
      },
      {
        title: "Team #{team_index + 1} Project Update",
        description: 'Share progress updates on ongoing projects',
        category: 'Updates',
        emoji: '📊',
        tags: 'project,update,progress',
        is_default: false
      },
      {
        title: "Team #{team_index + 1} Achievement",
        description: 'Celebrate team accomplishments and milestones',
        category: 'Success',
        emoji: '🎯',
        tags: 'achievement,milestone,celebration',
        is_default: false
      },
      {
        title: "Team #{team_index + 1} Internal Communication",
        description: 'Share important internal updates with the team',
        category: 'Communication',
        emoji: '💬',
        tags: 'internal,communication,update',
        is_default: false
      }
    ]


    team_templates.each do |template_attrs|
      Template.create!(
        company: company,
        team: team,
        **template_attrs
      )
      Rails.logger.debug { "Created team template: #{template_attrs[:title]} for team: #{team.name}" }
    end
  end
end

# Create or find test company
begin
  company = Company.find_or_create_by!(name: 'Test Company') do |c|
    c.code = 'TESTCODE'
    Rails.logger.debug { "Creating new company: #{c.name} with code: #{c.code}" }
  end

  # Create or find team for the company
  team = company.teams.find_or_create_by!(name: 'Test Team') do |t|
    t.code = "TESTTEAMCODE_#{company.id}"
    Rails.logger.debug { "Creating new team: #{t.name} with code: #{t.code}" }
  end

  # Create a team member for the test team
  test_user = users.first # Use one of the existing users
  test_team_member = team.team_members.find_or_create_by!(user: test_user) do |tm|
    # Assuming role_id is needed, use a default or an appropriate one
    tm.role_id = 1 # Adjust this role_id as per your application's logic
    Rails.logger.debug { "Creating new team member for #{team.name}: #{test_user.username}" }
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
    Strategy.find_or_create_by!(
      description: strategy_attrs[:description],
      company: company,
      team_member: test_team_member # Use the newly created test_team_member
    ) do |s|
      s.status = strategy_attrs[:status]
      s.from_schedule = strategy_attrs[:from_schedule]
      s.to_schedule = strategy_attrs[:to_schedule]
      Rails.logger.debug { "Creating new strategy: #{s.description} with status: #{s.status}" }
    end
  end

  Rails.logger.debug "\nSeed Summary:"
  Rails.logger.debug { "Company: #{company.name} (ID: #{company.id})" }
  Rails.logger.debug { "Team: #{team.name} (ID: #{team.id})" }
  Rails.logger.debug { "Team Member: #{test_team_member.user.username} (ID: #{test_team_member.id})" }
  Rails.logger.debug { "Strategies: #{Strategy.where(company: company).count}" }
  Rails.logger.debug { "Strategy IDs: #{Strategy.where(company: company).pluck(:id)}" }
rescue ActiveRecord::RecordInvalid => e
  Rails.logger.debug { "Error creating records: #{e.message}" }
  Rails.logger.debug { "Backtrace: #{e.backtrace[0..5].join("\n")}" }
  raise e
end

Rails.logger.debug 'Seeding completed successfully!'


# E2E deterministic registration test seed
company = Company.find_or_create_by!(code: 'COMPANY123') do |c|
  c.name = 'E2E Test Company'
end

team = Team.find_or_create_by!(code: 'TEAM456', company: company) do |t|
  t.name = 'QA Team'
end

puts "Seeded company: #{company.name} (#{company.code})"
puts "Seeded team: #{team.name} (#{team.code})"

# Add a user with fixed credentials for E2E login tests (read from ENV or use defaults)
e2e_user_email = ENV.fetch('E2E_LOGIN_USER_EMAIL', 'change_user_test@mail.com')
e2e_user_username = ENV.fetch('E2E_LOGIN_USER_USERNAME', 'change_user_test')
e2e_user_password = ENV.fetch('E2E_LOGIN_USER_PASSWORD', 'change_user_test')

user = User.find_or_create_by!(email: e2e_user_email) do |u|
  u.username = e2e_user_username
  u.password = e2e_user_password
  u.password_confirmation = e2e_user_password
end

# Ensure the user has the EMPLOYER role for dashboard access
unless user.has_role?(:employer)
  user.add_role(:employer)
end

# Ensure the user is a member of the deterministic E2E team
TeamMember.find_or_create_by!(user: user, team: team) do |tm|
  tm.role_id = 1 # Adjust as needed
end

puts "Seeded E2E login user: #{user.username} (#{user.email}) in team: #{team.name}"

# Add at least one strategy for TEAM456 with published=false
strategy = Strategy.find_or_create_by!(
  description: 'E2E Registration Strategy',
  company: company,
  team_member: team.team_members.first || TeamMember.create!(user: User.first, team: team, role_id: 1)
) do |s|
  s.status = 0 # pending
  s.from_schedule = Time.current
  s.to_schedule = 1.week.from_now
end

# Add at least one post for that strategy with published=false
Post.find_or_create_by!(
  title: 'E2E Registration Post',
  strategy: strategy,
  team_member: strategy.team_member
) do |p|
  p.description = 'A post for E2E registration test.'
  p.tags = 'e2e,test'
  p.image_url = 'https://commons.wikimedia.org/wiki/File:Cavalier_Garde_R%C3%A9publicaine_trois-quart_dos.jpg#/media/File:Cavalier_Garde_R%C3%A9publicaine_trois-quart_dos.jpg'
  p.programming_date_to_post = Time.current
  p.status = 0
  p.is_published = false
  p.emoji = '🧪'
  p.category = 'Test'
end

# Add at least one template for COMPANY123 and TEAM456

Template.find_or_create_by!(
  company: company,
  team: team,
  title: 'E2E Registration Template',
  description: 'Template for E2E registration test.',
  category: 'Test',
  emoji: '🧪',
  tags: 'e2e,template',
  is_default: false
)
