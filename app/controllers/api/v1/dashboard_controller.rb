# frozen_string_literal: true

module Api
  module V1
    class DashboardController < ApplicationController
      before_action :authenticate_user!
      before_action :check_user_permissions

      # GET /api/v1/dashboard/employer_metrics
      def employer_metrics
        user = current_user
        team_member = user.team_member

        unless team_member&.team&.company_id
          return render json: success_response(zero_metrics),
                        status: :ok
        end

        company_id = team_member.team.company_id

        begin
          total_strategies = Strategy.where(company_id: company_id).count
          total_posts = Post.joins(:strategy).where(strategies: { company_id: company_id }).count
          published_posts = Post.joins(:strategy).where(strategies: { company_id: company_id }, status: 2).count
          failed_posts = Post.joins(:strategy).where(strategies: { company_id: company_id }, status: [3, 4, 5, 6]).count
          pending_posts = Post.joins(:strategy).where(strategies: { company_id: company_id }, status: 0).count

          posts_per_strategy = Strategy.left_joins(:posts)
                                       .where(company_id: company_id)
                                       .group('strategies.id, strategies.description')
                                       .pluck('strategies.description, COUNT(posts.id)')
                                       .map { |description, count| { strategy: description, count: count } }

          metrics = {
            totalStrategies: total_strategies,
            totalPosts: total_posts,
            publishedPosts: published_posts,
            failedPosts: failed_posts,
            pendingPosts: pending_posts,
            postsPerStrategy: posts_per_strategy
          }

          render json: success_response(metrics), status: :ok
        rescue StandardError => e
          Rails.logger.error "Error calculating employer metrics: #{e.message}\n#{e.backtrace.join("\n")}"
          render json: success_response(zero_metrics), status: :ok
        end
      end

      private

      def check_user_permissions
        return if current_user.has_role?(:admin) || current_user.has_role?(:employer)

        render json: error_response(['Insufficient permissions to access dashboard']), status: :forbidden
      end

      def zero_metrics
        {
          totalStrategies: 0,
          totalPosts: 0,
          publishedPosts: 0,
          failedPosts: 0,
          pendingPosts: 0,
          postsPerStrategy: []
        }
      end

      # Response Helpers
      def success_response(resource)
        { status: { code: 200, message: I18n.t('responses.success') } }.merge(resource)
      end

      def error_response(errors)
        { status: { code: 422, message: I18n.t('responses.error') }, errors: errors }
      end
    end
  end
end
