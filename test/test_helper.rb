# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment" # Loads Rails application

# ---- BEGIN MANUAL ActiveRecord::Encryption CONFIG ----
# Attempt to load and configure ActiveRecord::Encryption directly
# This is to ensure it's set before models are loaded or tests run.
begin
  puts "Attempting to directly configure ActiveRecord::Encryption in test_helper.rb..."
  key_path = Rails.root.join('config/credentials/test.key')
  content_path = Rails.root.join('config/credentials/test.yml.enc')

  if File.exist?(key_path) && File.exist?(content_path)
    master_key = File.read(key_path).strip
    
    config_file = ActiveSupport::EncryptedFile.new(
      content_path: content_path,
      key_path: key_path, # Corrected: use key_path
      env_key: 'RAILS_MASTER_KEY_FOR_TEST_HELPER_DIRECT', # Should be ignored if key_path is valid
      raise_if_missing_key: true
    )
    decrypted_credentials_yaml = config_file.read
    credentials = YAML.load(decrypted_credentials_yaml) || {}
    
    ar_encrypt_creds = credentials['active_record_encryption']

    if ar_encrypt_creds && ar_encrypt_creds['primary_key']
      puts "Found primary_key. Configuring ActiveRecord::Encryption directly."
      
      # Use values from credentials or generate new ones if missing
      # Ensure keys are in binary format if OpenSSL::Random.random_bytes is used,
      # or hex if that's what your KDF expects.
      # The keys in yml are hex, so they need to be converted to binary for .configure
      # if they are intended as raw keys.
      # However, ActiveRecord::Encryption.configure usually expects these as hex strings
      # and derives binary keys from them.
      
      primary_h_key = ar_encrypt_creds['primary_key']
      deterministic_h_key = ar_encrypt_creds['deterministic_key'] || OpenSSL::Random.random_bytes(32).unpack1('H*')
      key_derivation_s = ar_encrypt_creds['key_derivation_salt'] || OpenSSL::Random.random_bytes(32).unpack1('H*')

      ActiveRecord::Encryption.configure(
        primary_key: primary_h_key,
        deterministic_key: deterministic_h_key,
        key_derivation_salt: key_derivation_s
      )
      puts "ActiveRecord::Encryption.config.primary_key set directly."
    else
      puts "active_record_encryption.primary_key NOT found in decrypted test credentials for direct config."
    end
  else
    puts "test.key or test.yml.enc NOT found for direct config in test_helper.rb."
  end
rescue StandardError => e
  puts "Error during direct ActiveRecord::Encryption config in test_helper.rb: #{e.class} - #{e.message}"
end
# ---- END MANUAL ActiveRecord::Encryption CONFIG ----

require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
