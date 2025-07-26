# frozen_string_literal: true

# Session controller
module Api
  module V1
    module Users
      # Devise session controller
      class SessionsController < Devise::SessionsController
        include RackSessionFix
        before_action :configure_sign_in_params, only: [:create]
        respond_to :json

        # GET /resource/sign_in
        # def new
        #   super
        # end

        # POST /resource/sign_in
        def create
          self.resource = warden.authenticate(auth_options)
          if resource
            set_flash_message!(:notice, :signed_in) if respond_to?(:set_flash_message!)
            sign_in(resource_name, resource)
            yield resource if block_given?
            respond_with(resource)
          else
            respond_with(nil)
          end
        end

        # DELETE /resource/sign_out
        # def destroy
        #   super
        # end

        # GET /me
        def me
          current_user = find_user_from_token
          if current_user
            render json: { user: current_user&.user_json_response }, status: :ok
          else
            render json: { error: 'Unauthorized' }, status: :unauthorized
          end
        end

        # PATCH/PUT /me
        def update
          Rails.logger.info "Update request received for user: #{current_user&.id}"
          Rails.logger.info "Update params: #{params.inspect}"

          if current_user&.update(user_params)
            Rails.logger.info "User updated successfully. New did_tutorial value: #{current_user.did_tutorial}"
            render json: { user: current_user.user_json_response }, status: :ok
          else
            Rails.logger.error "Failed to update user: #{current_user&.errors&.full_messages}"
            render json: { errors: current_user&.errors&.full_messages }, status: :unprocessable_entity
          end
        end

        private

        # If you have extra params to permit, append them to the sanitizer.
        def configure_sign_in_params
          devise_parameter_sanitizer.permit(:sign_in, keys: %i[email password])
        end

        def respond_with(current_user, _opts = {})
          render json: {
            status: {
              code: current_user ? 200 : 401,
              message: I18n.t(current_user ? 'devise.sessions.signed_in' : 'devise.sessions.invalid_login')
            },
            user: current_user&.user_json_response
          }, status: current_user ? :ok : :unauthorized
        end

        def respond_to_on_destroy
          current_user = find_user_from_token
          render json: {
            status: {
              code: current_user ? 200 : 401,
              message: I18n.t(current_user ? 'devise.sessions.signed_out' : 'devise.sessions.already_signed_out')
            }
          }, status: current_user ? :ok : :unauthorized
        end

        def find_user_from_token
          token = request.headers['Authorization']&.split(/\s+/)&.last
          return unless token

          jwt_payload = JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!).first
          User.find_by(id: jwt_payload['sub'])
        end

        def user_params
          params.require(:user).permit(:did_tutorial)
        end
      end
    end
  end
end
