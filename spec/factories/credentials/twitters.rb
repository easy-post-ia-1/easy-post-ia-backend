# frozen_string_literal: true

# == Schema Information
#
# Table name: credentials_twitters
#
#  id                  :bigint           not null, primary key
#  access_token        :text
#  access_token_secret :text
#  api_key             :text
#  api_key_secret      :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  company_id          :bigint           not null
#
# Indexes
#
#  index_credentials_twitters_on_company_id  (company_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (company_id => companies.id)
#
FactoryBot.define do
  factory :credentials_twitter, class: 'Credentials::Twitter' do
    api_key { 'test_api_key' }
    api_key_secret { 'test_api_secret' }
    access_token { 'test_access_token' }
    access_token_secret { 'test_access_secret' }
    company
  end

  factory :twitter_credential, class: 'Credentials::Twitter' do
    company
    api_key { 'test_api_key' }
    api_key_secret { 'test_api_secret' }
    access_token { 'test_access_token' }
    access_token_secret { 'test_access_secret' }
  end
end
