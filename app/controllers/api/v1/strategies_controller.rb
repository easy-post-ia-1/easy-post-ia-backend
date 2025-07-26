# frozen_string_literal: true

# Strategies controller @pagy.items
module Api
  module V1
    # Strategies controller
    class StrategiesController < ApplicationController
      before_action :authenticate_user!
      before_action :validate_params, only: [:create]
      before_action :set_pagination_params, only: [:index]
      before_action :set_strategy, only: [:show]

      # GET /api/v1/strategies
      def index
        @pagy, @strategies = pagy(current_user.strategies, items: @page_size)
        render json: success_response({
                                        strategies: @strategies.as_json(methods: [:posts_count],
                                                                        include: { posts: { only: [:id] } }),
                                        pagination: pagy_metadata(@pagy)
                                      }), status: :ok
      end

      # GET /api/v1/strategies/:id
      def show
        if @strategy
          render json: success_response(strategy: @strategy.as_json(methods: [:posts_count], include: { posts: { only: [:id] } })),
                 status: :ok
        else
          render json: error_response(['Strategy not found']), status: :not_found
        end
      end

      # POST /api/v1/strategies
      def create
        # Get the current user's team member and company
        team_member = current_user.team_member
        company = team_member.team.company

        unless team_member && company
          render json: error_response(['User is not associated with a team or company']), status: :unprocessable_entity
          return
        end

        # Create the strategy record first
        strategy = Strategy.create!(
          description: strategy_params[:description],
          from_schedule: strategy_params[:from_schedule],
          to_schedule: strategy_params[:to_schedule],
          team_member: team_member,
          company: company,
          status: :pending
        )

        # Pass the strategy data to the job
        strategy_data = strategy_params.merge(
          creator_id: current_user.id,
          strategy_id: strategy.id
        )

        res = CreateMarketingStrategyJob.perform_now(strategy_data)
        render json: creation_success_response(res), status: :created
      rescue ActiveRecord::RecordInvalid => e
        render json: error_response(e.record.errors.full_messages), status: :unprocessable_entity
      rescue StandardError => e
        render json: error_response([e.message]), status: :unprocessable_entity
      end

      private

      def set_pagination_params
        @page = params[:page]&.to_i || 1
        @page_size = params[:page_size]&.to_i || 10
      end

      def pagy_metadata(pagy_obj)
        {
          page: pagy_obj.page,
          per_page: pagy_obj.vars[:items],
          pages: pagy_obj.pages,
          count: pagy_obj.count
        }
      end

      def strategy_params
        params.permit(:from_schedule, :to_schedule, :description)
      end

      def validate_params
        required_params = %i[from_schedule to_schedule description]
        missing_params = required_params.select { |param| params[param].blank? }

        return unless missing_params.any?

        render json: error_response(["Missing parameters: #{missing_params.join(', ')}"]),
               status: :unprocessable_entity
      end

      def set_strategy
        @strategy = current_user.strategies.find_by(id: params[:id])
      end

      # Response Helpers
      def success_response(resource)
        { status: { code: 200, message: I18n.t('responses.success') } }.merge(resource)
      end

      def creation_success_response(strategy)
        {
          status: { code: 201, message: I18n.t('responses.created') },
          strategy: {
            id: strategy[:strategy_id],
            status: strategy[:status]
          }
        }
      end

      def error_response(errors)
        { status: { code: 422, message: I18n.t('responses.error') }, errors: errors }
      end
    end
  end
end
