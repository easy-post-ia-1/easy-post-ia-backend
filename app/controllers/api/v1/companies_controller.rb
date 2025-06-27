# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < ApplicationController
      before_action :authenticate_user!, only: [:social_network_status, :show] # Protect these endpoints

      # GET /api/v1/me/company_social_status
      def social_network_status
        user = current_user
        unless user.team && user.team.company
          render json: error_response(['User is not associated with a company.']), status: :not_found
          return
        end

        company = user.team.company
        credentials = company.credentials_twitter
        has_twitter_creds = credentials&.has_credentials? || false

        render json: success_response(
          social_networks: {
            twitter: {
              has_credentials: has_twitter_creds
            }
            # Placeholder for other social networks if any
            # e.g. facebook: { has_credentials: company.credentials_facebook&.has_credentials? || false }
          }
        ), status: :ok
      end

      # GET /api/v1/companies/:id
      def show
        company = Company.find_by(id: params[:id])
        if company
          # Select only safe attributes to expose
          render json: success_response(company: company.as_json(only: [:id, :name])), status: :ok
        else
          render json: error_response(['Company not found.']), status: :not_found
        end
      end

      private

      # Assuming these are not yet in ApplicationController for this subtask's scope.
      # If they are, these local definitions can be removed.
      def success_response(resource)
        { status: { code: 200, message: I18n.t('responses.success', default: 'Success') } }.merge(resource)
      end

      def error_response(errors_array)
        { status: { code: 422, message: I18n.t('responses.error', default: 'Error') }, errors: errors_array }
      end
    end
  end
end
