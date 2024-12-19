# frozen_string_literal: true

# Strategies controller
class StrategiesController < ApplicationController
  before_action :validate_params, only: [:create]

  def create
    # Process the data
    from_schedule = params[:from_schedule]
    to_schedule = params[:to_schedule]
    description = params[:description]

    # Job to process the strategy
    CreateMarketingStrategyJob.perform_later(from_schedule, to_schedule, description)

    render json: { status: :ok, messsage: 'ok', data: { idProccess: 1 } }
  end

  private

  def validate_params
    required_params = %i[from_schedule to_schedule description]
    missing_params = required_params.select { |param| params[param].blank? }

    return unless missing_params.any?

    render json: { error: "Missing parameters: #{missing_params.join(', ')}" }, status: :unprocessable_entity
  end
end
