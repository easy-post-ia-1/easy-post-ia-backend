# frozen_string_literal: true

# config/initializers/cors.rb
# TODO: Confiure variable
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://localhost:3000', 'http://localhost:5173', '192.168.65.1'
    resource(
      '*',
      headers: :any,
      expose: %w[access-token expiry token-type Authorization],
      methods: %i[get patch put delete post options show]
    )
  end
end
