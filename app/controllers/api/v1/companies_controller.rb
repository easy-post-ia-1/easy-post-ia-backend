# frozen_string_literal: true

module Api
  module V1
    class CompaniesController < ApplicationController
      before_action :authenticate_user!, only: %i[social_network_status show]

      # GET /api/v1/me/company_social_status
      def social_network_status
        user = current_user
        unless user.team&.company
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
          render json: success_response(company: company.as_json(only: %i[id name])), status: :ok
        else
          render json: error_response(['Company not found.']), status: :not_found
        end
      end
    end
  end
end
