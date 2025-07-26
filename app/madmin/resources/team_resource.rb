# frozen_string_literal: true

# Team Resource
class TeamResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :name
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :team_members, form: false, show: false
  attribute :users, form: false, show: false
  attribute :strategies, form: false, show: false
  attribute :posts, form: false, show: false

  # Add scopes to easily filter records
  # scope :published

  # Add actions to the resource's show page
  # member_action do |record|
  #   link_to "Do Something", some_path
  # end

  # Customize the display name of records in the admin area.
  def self.display_name(record)
    record.name
  end

  # Customize the default sort column and direction.
  def self.default_sort_column
    'created_at'
  end

  def self.default_sort_direction
    'desc'
  end
end
