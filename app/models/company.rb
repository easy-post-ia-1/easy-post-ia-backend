# frozen_string_literal: true

# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Company < ApplicationRecord
  has_many :users
  has_many :teams
  has_many :team_members, through: :teams
  has_many :posts, through: :team_members
  has_many :strategies, through: :team_members
  has_one :credentials_twitter, class_name: 'Credentials::Twitter', dependent: :destroy

  # Add validations as needed
end
