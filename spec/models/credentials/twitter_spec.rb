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
require 'rails_helper'

RSpec.describe Credentials::Twitter do
  describe 'associations' do
    it { should belong_to(:company) }
  end

  describe 'validations' do
    subject { build(:credentials_twitter) }
    
    it { should validate_uniqueness_of(:company_id) }
  end

  describe '#has_credentials?' do
    let(:company) { create(:company) }
    let(:twitter_credentials) { build(:credentials_twitter, company: company) }

    context 'when all credentials are present' do
      before do
        twitter_credentials.api_key = 'test_api_key'
        twitter_credentials.api_key_secret = 'test_api_secret'
        twitter_credentials.access_token = 'test_access_token'
        twitter_credentials.access_token_secret = 'test_access_secret'
      end

      it 'returns true' do
        expect(twitter_credentials.has_credentials?).to be true
      end
    end

    context 'when api_key is missing' do
      before do
        twitter_credentials.api_key = nil
        twitter_credentials.api_key_secret = 'test_api_secret'
        twitter_credentials.access_token = 'test_access_token'
        twitter_credentials.access_token_secret = 'test_access_secret'
      end

      it 'returns false' do
        expect(twitter_credentials.has_credentials?).to be false
      end
    end

    context 'when api_key_secret is missing' do
      before do
        twitter_credentials.api_key = 'test_api_key'
        twitter_credentials.api_key_secret = nil
        twitter_credentials.access_token = 'test_access_token'
        twitter_credentials.access_token_secret = 'test_access_secret'
      end

      it 'returns false' do
        expect(twitter_credentials.has_credentials?).to be false
      end
    end

    context 'when access_token is missing' do
      before do
        twitter_credentials.api_key = 'test_api_key'
        twitter_credentials.api_key_secret = 'test_api_secret'
        twitter_credentials.access_token = nil
        twitter_credentials.access_token_secret = 'test_access_secret'
      end

      it 'returns false' do
        expect(twitter_credentials.has_credentials?).to be false
      end
    end

    context 'when access_token_secret is missing' do
      before do
        twitter_credentials.api_key = 'test_api_key'
        twitter_credentials.api_key_secret = 'test_api_secret'
        twitter_credentials.access_token = 'test_access_token'
        twitter_credentials.access_token_secret = nil
      end

      it 'returns false' do
        expect(twitter_credentials.has_credentials?).to be false
      end
    end

    context 'when all credentials are missing' do
      before do
        twitter_credentials.api_key = nil
        twitter_credentials.api_key_secret = nil
        twitter_credentials.access_token = nil
        twitter_credentials.access_token_secret = nil
      end

      it 'returns false' do
        expect(twitter_credentials.has_credentials?).to be false
      end
    end
  end
end
