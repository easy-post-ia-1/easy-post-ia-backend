# frozen_string_literal: true

# Strategies controller
module Api
  module V1
    # Strategies controller
    class StrategiesController < ApplicationController
      before_action :authenticate_user!
      before_action :validate_params, only: [:create] # Existing before_action for create
      before_action :set_pagination_params, only: [:index]

      # GET /api/v1/strategies
      def index
        unless current_user.team
          render json: error_response(['User is not associated with a team.'], :unprocessable_entity), status: :unprocessable_entity
          return
        end

        team = current_user.team
        # Query to get distinct strategy IDs associated with the user's team
        distinct_strategy_ids_query = Strategy.joins(posts: { team_member: :team })
                                              .where(teams: { id: team.id })
                                              .distinct # This applies to what's selected by pluck
                                              .order(created_at: :desc)

        # Pluck both id and created_at to satisfy "ORDER BY expressions must appear in select list"
        # when using DISTINCT.
        distinct_strategy_data = distinct_strategy_ids_query.pluck(:id, :created_at)
        distinct_strategy_ids = distinct_strategy_data.map(&:first) # Extract just IDs

        # Paginate the array of distinct strategy IDs
        @pagy = Pagy.new(count: distinct_strategy_ids.size, items: @page_size, page: @page)
        paginated_ids_for_current_page = distinct_strategy_ids[@pagy.offset, @pagy.limit]

        # Fetch the actual Strategy records for the current page's IDs
        # Order them by the order of paginated_ids_for_current_page to respect the original sort.
        # Avoid SQL injection with join by ensuring paginated_ids are integers.
        if paginated_ids_for_current_page.empty?
          strategies = Strategy.none # Return an empty relation if no IDs for the page
        else
          safe_paginated_ids_list = paginated_ids_for_current_page.map(&:to_i).join(',')
          strategies = Strategy.where(id: paginated_ids_for_current_page)
                               .order(Arel.sql("array_position(ARRAY[#{safe_paginated_ids_list}]::bigint[], strategies.id)"))
        end

        render json: success_response(
          strategies: strategies.map do |strategy|
            {
              id: strategy.id,
              description: strategy.description,
              status_display: strategy.status_display, # Uses the new model method
              from_schedule: strategy.from_schedule,
              to_schedule: strategy.to_schedule,
              # Ensure post_ids are also from the same team's members
              post_ids: strategy.posts.where(team_member_id: team.team_member_ids).pluck(:id)
            }
          end,
          pagination: pagy_metadata(@pagy)
        ), status: :ok
      end

      # Existing create action
      # For testing purposing perform now
      def create
        strategy_data = strategy_params.merge(creator_id: current_user.id)
        res = CreateMarketingStrategyJob.perform_now(strategy_data)
        render json: { status: { code: 200, message: 'strategy created' },
                       data: { strategy_status: res[:status], strategy_id: res[:strategy_id] } }
      end

      private

      def set_pagination_params
        @page = params[:page]&.to_i || 1
        @page_size = params[:page_size]&.to_i || 10
      end

      def pagy_metadata(pagy_obj)
        {
          page: pagy_obj.page,
          per_page: pagy_obj.limit, # Corrected to .limit
          pages: pagy_obj.pages,
          count: pagy_obj.count
        }
      end

      def success_response(resource)
        { status: { code: 200, message: I18n.t('responses.success', default: 'Success') } }.merge(resource)
      end

      def error_response(errors_array, status_code_or_symbol = 422)
        numeric_status_code = Rack::Utils.status_code(status_code_or_symbol)
        { status: { code: numeric_status_code, message: I18n.t('responses.error', default: 'Error') }, errors: errors_array }
      end

      # Existing private methods for create action
      def strategy_params
        params.permit(:from_schedule, :to_schedule, :description)
      end

      def validate_params
        required_params = %i[from_schedule to_schedule description]
        missing_params = required_params.select { |param| params[param].blank? }

        return unless missing_params.any?

        # Using the new error_response helper for consistency, though create action uses a different format.
        # For this subtask, just ensuring error_response is available.
        # If create were to be refactored, it could use this too.
        render json: { error: "Missing parameters: #{missing_params.join(', ')}" },
               status: :unprocessable_entity
      end
    end
  end
end
