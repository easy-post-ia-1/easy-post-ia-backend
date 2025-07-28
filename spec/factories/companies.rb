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
FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    code { Faker::Alphanumeric.alphanumeric(number: 8).upcase }

    trait :with_twitter_credentials do
      after(:create) do |company|
        create(:credentials_twitter, company: company)
      end
    end

    trait :with_incomplete_twitter_credentials do
      after(:create) do |company|
        create(:credentials_twitter, company: company, api_key: 'key', api_key_secret: nil)
      end
    end
  end
end
