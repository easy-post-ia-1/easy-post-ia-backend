# frozen_string_literal: true

# Post resource
class PostResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :title
  attribute :description
  attribute :image_url
  attribute :tags
  attribute :category
  attribute :emoji
  attribute :programming_date_to_post
  attribute :is_published
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :team_member
  attribute :strategy

  # Add scopes to easily filter records
  scope :published
  scope :unpublished

  # Add actions to the resource's show page
  # member_action do |record|
  #   link_to "Do Something", some_path
  # end

  # Customize the display name of records in the admin area.
  def self.display_name(record)
    record.title
  end

  # Customize the default sort column and direction.
  def self.default_sort_column
    'created_at'
  end

  def self.default_sort_direction
    'desc'
  end
end
