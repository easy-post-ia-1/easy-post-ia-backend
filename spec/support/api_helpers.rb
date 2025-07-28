# frozen_string_literal: true

require 'jwt'

module ApiHelpers
  def generate_jwt_token_for_user(user = nil)
    # If no user is provided, create a default user for testing
    user ||= create(:user)
    
    payload = {
      sub: user.id,
      scp: 'user', # Scope, ensure this matches your Devise setup if applicable
      aud: nil,    # Audience, ensure this matches
      iat: Time.now.to_i,
      exp: 1.hour.from_now.to_i, # Token expiration time
      jti: SecureRandom.uuid
    }
    # Ensure Rails.application.credentials.devise_jwt_secret_key! is valid and loaded
    # For test environment, you might need to ensure credentials are set if not using Figaro/ENV vars
    # For example, directly access if Rails credentials are set up for test:
    secret_key = Rails.application.credentials.devise_jwt_secret_key
    unless secret_key
      # Fallback for environments where Rails credentials might not be fully loaded in tests
      # or if you are using a different way to store this specific key for tests.
      # This is a common pattern if ENV vars are used in config/initializers/devise.rb
      secret_key = ENV.fetch('DEVISE_JWT_SECRET_KEY', nil)
      if secret_key.blank? && Rails.env.test?
        # Provide a default dummy key for tests if none is found, but log a warning.
        # This ensures tests can run but highlights a potential configuration gap.
        Rails.logger.warn 'DEVISE_JWT_SECRET_KEY not found in Rails credentials or ENV for test. Using a default dummy key. Ensure this is configured for real authentication.'
        secret_key = 'dummy_test_secret_key_min_32_chars_long_for_hs256'
      elsif secret_key.blank?
        raise 'DEVISE_JWT_SECRET_KEY is missing. Cannot generate JWT.'
      end
    end
    JWT.encode(payload, secret_key, 'HS256')
  end
end
