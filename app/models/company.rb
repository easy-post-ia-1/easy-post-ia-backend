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
  has_many :teams, dependent: :destroy
  has_many :strategies, dependent: :destroy
  has_one :credentials_twitter, class_name: 'Credentials::Twitter', dependent: :destroy
end
