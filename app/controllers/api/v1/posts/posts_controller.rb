# frozen_string_literal: true

module Api
  module V1
    module Posts
      # Posts Controller
      class PostsController < ApplicationController
        before_action :authenticate_user!
        before_action :set_post, only: %i[show destroy]
        before_action :set_post_for_update, only: %i[update]
        before_action :pagination_params, only: %i[index]
        before_action :authenticate_user!

        # GET /api/v1/posts
        def index
          page, page_size = pagination_params.values_at(:page, :page_size)
          from_date = params[:from_date]
          to_date = params[:to_date]
          title = params[:title]
          description = params[:description]
          tags = params[:tags]
          params[:status]
          is_published = params[:is_published]

          posts_scope = Post.where(team_member_id: current_user.team_member.id).order(updated_at: :desc)

          posts_scope = posts_scope.where(programming_date_to_post: from_date..) if from_date.present?

          posts_scope = posts_scope.where(programming_date_to_post: ..to_date) if to_date.present?

          posts_scope = posts_scope.where('title ILIKE ?', "%#{title}%") if title.present?

          posts_scope = posts_scope.where('description ILIKE ?', "%#{description}%") if description.present?

          if tags.present?
            # Handle tags as an array or string
            tag_array = tags.is_a?(Array) ? tags : tags.split(',')
            tag_conditions = tag_array.map { |_tag| 'tags ILIKE ?' }.join(' OR ')
            posts_scope = posts_scope.where(tag_conditions, *tag_array.map { |tag| "%#{tag}%" })
          end

          posts_scope = posts_scope.where(is_published: is_published) if is_published.present?

          @pagy, @records = pagy(posts_scope, items: page_size, page:)

          pagination = { page: @pagy.page, pages: @pagy.pages, count: @pagy.count }
          render json: success_response({ posts: @records, pagination: }), status: :ok
        end

        # GET /api/v1/posts/:id
        def show
          if current_user.team == @post.team
            render json: success_response(post: @post), status: :ok
          else
            render json: error_response('You are not authorized to view this post'), status: :unauthorized
          end
        end

        # POST /api/v1/posts
        def create
          post = Post.new(post_params)
          current = TeamMember.find_by(user_id: current_user.id)
          post.team_member_id = current.id

          if post.save
            render json: creation_success_response(post), status: :created
          else
            render json: error_response(post.errors.full_messages), status: :unprocessable_entity
          end
        end

        # PUT /api/v1/posts/:id
        def update
          if params[:id] == '-1' || @post.new_record?
            # Create new post when id is -1 or post is new
            post = Post.new(post_params)
            current = TeamMember.find_by(user_id: current_user.id)
            post.team_member_id = current.id

            if post.save
              render json: creation_success_response(post), status: :created
            else
              render json: error_response(post.errors.full_messages), status: :unprocessable_entity
            end
          elsif current_user.team == @post.team && @post.update(post_params)
            render json: success_response(post: @post), status: :ok
          elsif current_user.team != @post.team
            render json: error_response('You are not authorized to update this post'), status: :unauthorized
          else
            render json: error_response(@post.errors.full_messages), status: :unprocessable_entity
          end
        end

        # DELETE /api/v1/posts/:id
        def destroy
          if current_user.team == @post.team
            @post.destroy
            render json: deletion_success_response, status: :ok
          else
            render json: error_response('You are not authorized to delete this post'), status: :unauthorized
          end
        end

        private

        # Strong Parameters
        def post_params
          params.require(:post).permit(:id, :title, :description, :tags, :category, :emoji, :programming_date_to_post, :team_member_id,
                                       :strategy_id, :is_published, :image_url)
        end

        def pagination_params
          {
            page: params[:page]&.to_i || 1,
            page_size: params[:page_size]&.to_i || 10
          }
        end

        # Set Post
        def set_post
          @post = Post.find_by(id: params[:id])
          render json: error_response(['Post not found']), status: :not_found unless @post
        end

        # Set Post for Update
        def set_post_for_update
          if params[:id] == '-1'
            @post = nil
          else
            @post = Post.find_by(id: params[:id])
            render json: error_response(['Post not found']), status: :not_found unless @post
          end
        end

        # Response Helpers
        def success_response(resource)
          { status: { code: 200, message: I18n.t('responses.success') } }.merge(resource)
        end

        def creation_success_response(post)
          { status: { code: 201, message: I18n.t('responses.created') }, post: }
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
end
