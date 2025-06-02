# frozen_string_literal: true

# Strategies controller
module Api
  module V1
    # Strategies controller
    class StrategiesController < ApplicationController
      before_action :authenticate_user!
      before_action :validate_params, only: [:create]

      # For testing purposing perform now
      def create
        strategy_data = strategy_params.merge(creator_id: current_user.id)
        res = CreateMarketingStrategyJob.perform_now(strategy_data)
        render json: { status: { code: 200, message: 'strategy created' },
                       data: { strategy_status: res[:status], strategy_id: res[:strategy_id] } }
      end

      private

      def strategy_params
        params.permit(:from_schedule, :to_schedule, :description)
      end

      def validate_params
        required_params = %i[from_schedule to_schedule description]
        missing_params = required_params.select { |param| params[param].blank? }

        return unless missing_params.any?

        render json: { error: "Missing parameters: #{missing_params.join(', ')}" },
               status: :unprocessable_entity
      end
    end
  end
end
