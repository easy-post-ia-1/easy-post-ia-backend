# frozen_string_literal: true

class StrategyResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :name
  attribute :description
  attribute :status
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :team_member
  attribute :posts, show: false, form: false

  # Customize the display name of records in the admin:
  def self.display_name(record)
    record.description
  end

  # Customize the default sort column and direction:
  def self.default_sort_column
    "created_at"
  end

  def self.default_sort_direction
    "desc"
  end
end
