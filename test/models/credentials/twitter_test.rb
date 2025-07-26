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
require 'test_helper'

module Credentials
  class TwitterTest < ActiveSupport::TestCase
    setup do
      puts "RAILS_ENV in Test: #{Rails.env}"
      puts "Credentials Key Path: #{Rails.application.config.credentials.key_path}"
      puts "Credentials Content Path: #{Rails.application.config.credentials.content_path}"
      puts "Loaded AR Encryption Primary Key in Test: #{Rails.application.credentials.active_record_encryption&.primary_key}"
      @company = companies(:one) # Assuming you have fixtures for companies
      # If not using fixtures, create a company:
      # @company = Company.create!(name: "TestCo")
    end

    test 'should create credentials twitter with valid attributes' do
      credentials = Credentials::Twitter.new(
        api_key: 'test_api_key',
        api_key_secret: 'test_api_key_secret',
        access_token: 'test_access_token',
        access_token_secret: 'test_access_token_secret',
        company: @company
      )
      assert credentials.save, "Failed to save Credentials::Twitter: #{credentials.errors.full_messages.join(', ')}"
    end

    test 'attributes should be encrypted' do
      api_key_plain = 'test_api_key_plain'
      api_key_secret_plain = 'test_api_key_secret_plain'
      access_token_plain = 'test_access_token_plain'
      access_token_secret_plain = 'test_access_token_secret_plain'

      credentials = Credentials::Twitter.create!(
        api_key: api_key_plain,
        api_key_secret: api_key_secret_plain,
        access_token: access_token_plain,
        access_token_secret: access_token_secret_plain,
        company: @company
      )

      # Check that the raw attribute is different from the plain text
      assert_not_equal api_key_plain, credentials.read_attribute_before_type_cast(:api_key)
      assert_not_equal api_key_secret_plain, credentials.read_attribute_before_type_cast(:api_key_secret)
      assert_not_equal access_token_plain, credentials.read_attribute_before_type_cast(:access_token)
      assert_not_equal access_token_secret_plain, credentials.read_attribute_before_type_cast(:access_token_secret)

      # Check that the decrypted value is correct after reloading
      credentials.reload
      assert_equal api_key_plain, credentials.api_key
      assert_equal api_key_secret_plain, credentials.api_key_secret
      assert_equal access_token_plain, credentials.access_token
      assert_equal access_token_secret_plain, credentials.access_token_secret
    end

    test 'should NOT populate default values from ENV and attributes should be nil' do
      with_env_values(
        'TWITTER_API_KEY' => 'env_api_key',
        'TWITTER_API_KEY_SECRET' => 'env_api_key_secret',
        'TWITTER_ACCESS_TOKEN' => 'env_access_token',
        'TWITTER_ACCESS_TOKEN_SECRET' => 'env_access_token_secret'
      ) do
        credentials = Credentials::Twitter.new(company: @company) # No params other than company
        assert_nil credentials.api_key
        assert_nil credentials.api_key_secret
        assert_nil credentials.access_token
        assert_nil credentials.access_token_secret
      end
    end

    test '#has_credentials? should return true if all keys and tokens are present' do
      credentials = Credentials::Twitter.new(
        api_key: 'key', api_key_secret: 'secret', access_token: 'token', access_token_secret: 'secret', company: @company
      )
      assert credentials.has_credentials?
    end

    test '#has_credentials? should return false if api_key is missing' do
      credentials = Credentials::Twitter.new(
        api_key_secret: 'secret', access_token: 'token', access_token_secret: 'secret', company: @company
      )
      assert_not credentials.has_credentials?
    end

    test '#has_credentials? should return false if api_key_secret is missing' do
      credentials = Credentials::Twitter.new(
        api_key: 'key', access_token: 'token', access_token_secret: 'secret', company: @company
      )
      assert_not credentials.has_credentials?
    end

    test '#has_credentials? should return false if access_token is missing' do
      credentials = Credentials::Twitter.new(
        api_key: 'key', api_key_secret: 'secret', access_token_secret: 'secret', company: @company
      )
      assert_not credentials.has_credentials?
    end

    test '#has_credentials? should return false if access_token_secret is missing' do
      credentials = Credentials::Twitter.new(
        api_key: 'key', api_key_secret: 'secret', access_token: 'token', company: @company
      )
      assert_not credentials.has_credentials?
    end

    test '#has_credentials? should return false if all credentials are blank' do
      credentials = Credentials::Twitter.new(
        api_key: '', api_key_secret: '', access_token: '', access_token_secret: '', company: @company
      )
      assert_not credentials.has_credentials?
    end

    test 'belongs_to company association' do
      credentials = Credentials::Twitter.create!(company: @company)
      assert_equal @company, credentials.company
    end

    test 'dependent destroy from company' do
      Credentials::Twitter.create!(company: @company)
      assert_difference('Credentials::Twitter.count', -1) do
        @company.destroy
      end
    end

    test 'company_id should be unique' do
      Credentials::Twitter.create!(
        api_key: 'test1',
        api_key_secret: 'test_secret1',
        access_token: 'token1',
        access_token_secret: 'token_secret1',
        company: @company
      )

      duplicate_credentials = Credentials::Twitter.new(
        api_key: 'test2',
        api_key_secret: 'test_secret2',
        access_token: 'token2',
        access_token_secret: 'token_secret2',
        company: @company # Same company
      )

      assert_not duplicate_credentials.valid?
      assert duplicate_credentials.errors[:company_id].any?, 'Should have an error on company_id for uniqueness'

      # To test for ActiveRecord::RecordNotUnique, we'd need to bypass validations and save
      # This is generally harder to test directly at the model level for unique DB constraints
      # without trying to save and catching the specific database exception.
      # The validation test above is usually sufficient for model tests.
      # Example for DB level check (might need specific DB setup or error handling):
      # assert_raises(ActiveRecord::RecordNotUnique) do
      #   duplicate_credentials.save(validate: false)
      # end
    end

    private

    # Helper method for stubbing ENV variables, Minitest specific
    def with_env_values(vars)
      original_values = {}
      vars.each_key { |k| original_values[k] = ENV.fetch(k, nil) }
      vars.each { |k, v| ENV[k] = v }
      yield
    ensure
      original_values.each { |k, v| ENV[k] = v }
    end
  end
end
