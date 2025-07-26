# frozen_string_literal: true

# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_companies_on_code  (code) UNIQUE
#
class Company < ApplicationRecord
  has_many :users
  has_many :teams
  has_many :team_members, through: :teams
  has_many :posts, through: :team_members
  has_many :strategies, through: :team_members
  has_many :templates, dependent: :destroy
  has_one :credentials_twitter, class_name: 'Credentials::Twitter', dependent: :destroy

  validates :code, presence: true, uniqueness: true
  # Add validations as needed
end
