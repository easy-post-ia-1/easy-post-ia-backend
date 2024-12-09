# frozen_string_literal: true

namespace :db do
  desc 'Destroy all seeded data'
  task destroy_seed: :environment do
    puts 'Cleaning up seeded data...'

    if Rails.env.production?
      puts 'This task cannot be run in production!'
      exit
    end

    begin
      # Destroy records in the correct order based on dependencies
      Post.delete_all
      TeamMember.delete_all
      Team.delete_all
      Company.delete_all
      User.delete_all

      puts 'All seeded data has been destroyed successfully!'
    rescue StandardError => e
      puts "An error occurred while cleaning up the database: #{e.message}"
    end
  end
end
