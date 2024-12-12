# frozen_string_literal: true

module Madmin
  class ApplicationController < Madmin::BaseController # rubocop:disable Style/Documentation
    before_action :authenticate_admin_user

    def authenticate_admin_user
      # TODO: Add your authentication logic here

      # For example, with Rails 8 authentication
      # redirect_to "/", alert: "Not authorized." unless authenticated? && Current.user.admin?

      # Or with Devise
      # redirect_to "/", alert: "Not authorized." unless current_user&.admin?
    end

    http_basic_authenticate_with(
      name: ENV['ADMIN_USERNAME'] || Rails.application.credentials.admin_username,
      password: ENV['ADMIN_PASSWORD'] || Rails.application.credentials.admin_password
    )
  end
end
