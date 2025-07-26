# frozen_string_literal: true

module Api
  module V1
    class TemplatesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_template, only: %i[show update destroy]
      before_action :pagination_params, only: %i[index]
      before_action :check_permissions, only: %i[create update destroy]

      # GET /api/v1/templates
      def index
        page, page_size = pagination_params.values_at(:page, :page_size)
        category = params[:category]
        title = params[:title]
        template_type = params[:template_type] # 'company' or 'team'

        user = current_user
        team_member = user.team_member
        unless team_member
          return render json: error_response(['User is not associated with a team.']),
                        status: :not_found
        end

        company_id = team_member.team.company_id
        team_id = team_member.team_id

        templates_scope = Template.available_for_team(team_id).by_company(company_id).order(updated_at: :desc)

        # Filter by category
        templates_scope = templates_scope.where(category: category) if category.present?

        # Filter by title
        templates_scope = templates_scope.where('title ILIKE ?', "%#{title}%") if title.present?

        # Filter by template type
        if template_type.present?
          case template_type
          when 'company'
            templates_scope = templates_scope.where(is_default: true, team_id: nil)
          when 'team'
            templates_scope = templates_scope.where(is_default: false)
          end
        end

        @pagy, @records = pagy(templates_scope, items: page_size, page:)

        pagination = { page: @pagy.page, pages: @pagy.pages, count: @pagy.count }
        render json: success_response({ templates: @records, pagination: }), status: :ok
      end

      # GET /api/v1/templates/:id
      def show
        if @template.can_be_accessed_by?(current_user)
          render json: success_response(template: @template), status: :ok
        else
          render json: error_response(['You are not authorized to view this template']), status: :unauthorized
        end
      end

      # POST /api/v1/templates
      def create
        user = current_user
        team_member = user.team_member
        unless team_member
          return render json: error_response(['User is not associated with a team.']),
                        status: :not_found
        end

        template = Template.new(template_params)
        template.company_id = team_member.team.company_id
        template.team_id = team_member.team_id
        template.is_default = false # User-created templates are never default

        if template.save
          render json: creation_success_response(template), status: :created
        else
          render json: error_response(template.errors.full_messages), status: :unprocessable_entity
        end
      end

      # PUT /api/v1/templates/:id
      def update
        if @template.can_be_managed_by?(current_user) && @template.update(template_params)
          render json: success_response(template: @template), status: :ok
        elsif !@template.can_be_managed_by?(current_user)
          render json: error_response(['You are not authorized to update this template']), status: :unauthorized
        else
          render json: error_response(@template.errors.full_messages), status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/templates/:id
      def destroy
        if @template.can_be_managed_by?(current_user)
          @template.destroy
          render json: deletion_success_response, status: :ok
        else
          render json: error_response(['You are not authorized to delete this template']), status: :unauthorized
        end
      end

      # GET /api/v1/templates/categories
      def categories
        user = current_user
        team_member = user.team_member
        unless team_member
          return render json: error_response(['User is not associated with a team.']),
                        status: :not_found
        end

        company_id = team_member.team.company_id
        team_id = team_member.team_id

        categories = Template.available_for_team(team_id)
                             .by_company(company_id)
                             .distinct
                             .pluck(:category, :emoji)
                             .map { |category, emoji| { category: category, emoji: emoji } }

        render json: success_response(categories: categories), status: :ok
      end

      private

      # Strong Parameters
      def template_params
        params.require(:template).permit(:title, :description, :image_url, :tags, :category, :emoji)
      end

      def pagination_params
        {
          page: params[:page]&.to_i || 1,
          page_size: params[:page_size]&.to_i || 5
        }
      end

      # Set Template
      def set_template
        @template = Template.find_by(id: params[:id])
        render json: error_response(['Template not found']), status: :not_found unless @template
      end

      # Check permissions for create/update/delete
      def check_permissions
        user = current_user
        team_member = user.team_member
        unless team_member
          return render json: error_response(['User is not associated with a team.']),
                        status: :not_found
        end

        return if user.has_role?(:admin) || user.has_role?(:employer)

        render json: error_response(['Insufficient permissions to manage templates']), status: :forbidden
      end

      # Response Helpers
      def success_response(resource)
        { status: { code: 200, message: I18n.t('responses.success') } }.merge(resource)
      end

      def creation_success_response(template)
        { status: { code: 201, message: I18n.t('responses.created') }, template: }
      end

      def deletion_success_response
        { status: { code: 200, message: I18n.t('responses.deleted') } }
      end

      def error_response(errors)
        { status: { code: 422, message: I18n.t('responses.error') }, errors: }
      end
    end
  end
end
