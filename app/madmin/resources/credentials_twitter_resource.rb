# frozen_string_literal: true

class Credentials::TwitterResource < Madmin::Resource
  # Attributes
  attribute :id, form: false
  attribute :api_key
  attribute :api_key_secret
  attribute :access_token
  attribute :access_token_secret
  attribute :created_at, form: false
  attribute :updated_at, form: false

  # Associations
  attribute :company

  # Uncomment this to customize the display name of records in the admin:
  # def self.display_name(record)
  #   "Twitter Credentials for #{record.company.name}"
  # end

  # Uncomment this to customize the default sort column and direction:
  # def self.default_sort_column
  #   "created_at"
  # end

  # def self.default_sort_direction
  #   "desc"
  # end
end 