# frozen_string_literal: true

# User Resource
class UserResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :email
  attribute :username
  attribute :did_tutorial
  attribute :remember_created_at
  attribute :reset_password_sent_at
  attribute :reset_password_token
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :company
  attribute :team_member
  attribute :team
  attribute :strategies
  attribute :posts
  attribute :roles

  # Add scopes to easily filter records
  # scope :published

  # Add actions to the resource's show page
  # member_action do |record|
  #   link_to "Do Something", some_path
  # end

  # Customize the display name of records in the admin area.
  def self.display_name(record)
    record.username || record.email
  end

  # Customize the default sort column and direction.
  def self.default_sort_column
    "created_at"
  end

  def self.default_sort_direction
    "desc"
  end
end
