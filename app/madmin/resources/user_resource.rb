# frozen_string_literal: true

# User Resource
class UserResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :email
  attribute :username
  attribute :did_tutorial
  attribute :role, :select, collection: ["EMPLOYER", "EMPLOYEE", "ADMIN"]

  # Associations
  attribute :team_name, :string, form: false
  attribute :strategies, form: false, show: false
  attribute :posts, form: false, show: false
  attribute :roles, form: false, show: false

  # Add scopes to easily filter records
  # scope :published

  # Add actions to the resource's show page
  # member_action do |record|
  #   link_to "Do Something", some_path
  # end

  # Customize the display name of records in the admin area.
  def self.display_name(record)
    record.username.presence || record.email.presence || "User ##{record.id}"
  end

  # Customize the default sort column and direction.
  def self.default_sort_column
    'created_at'
  end

  def self.default_sort_direction
    'desc'
  end

  def display_team_name(record)
    record.team&.name || "No team"
  end
end
