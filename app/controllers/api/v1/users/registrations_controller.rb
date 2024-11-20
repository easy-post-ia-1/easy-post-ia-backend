# frozen_string_literal: true

# UserAuth controlller
# Handle of the registration of the users
module Api
  module V1
    module Users
      # Controller in charge if the registration inheriting from Devise
      class RegistrationsController < Devise::RegistrationsController
        # before_action :configure_sign_up_params, only: [:create]
        # before_action :configure_account_update_params, only: [:update]

        # GET /resource/sign_up
        # def new
        #   super
        # end

        # POST /resource
        # def create
        #   super
        # end

        # GET /resource/edit
        # def edit
        #   super
        # end

        # PUT /resource
        # def update
        #   super
        # end

        # DELETE /resource
        # def destroy
        #   super
        # end

        # GET /resource/cancel
        # Forces the session data which is usually expired after sign
        # in to be expired now. This is useful if the user wants to
        # cancel oauth signing in/up in the middle of the process,
        # removing all OAuth session data.
        # def cancel
        #   super
        # end

        # protected

        # If you have extra params to permit, append them to the sanitizer.
        # def configure_sign_up_params
        #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
        # end

        # If you have extra params to permit, append them to the sanitizer.
        # def configure_account_update_params
        #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
        # end

        # The path used after sign up.
        # def after_sign_up_path_for(resource)
        #   super(resource)
        # end

        # The path used after sign up for inactive accounts.
        # def after_inactive_sign_up_path_for(resource)
        #   super(resource)
        # end
        include RackSessionFix
        before_action :initialize_user, only: [:create]
        respond_to :json

        def create
          if @user.valid? && @user.save
            render json: user_creation_success_response, status: :created
          else
            render json: user_creation_error_response, status: :unprocessable_entity
          end
        end

        # def respond_with(current_user, _opts = {})
        #   if resource.persisted?
        #     render json: {
        #       status: { code: 200, message: 'Signed up successfully.' },
        #       data: @user.user_json_response
        #     }, status: :ok
        #   else
        #     render json: {
        #       status: {
        #         message: "User couldn't be created successfully. #{current_user.errors.full_messages.to_sentence}"
        #       }
        #     }, status: :unprocessable_entity
        #   end
        # end

        private

        def initialize_user
          @user = User.new(user_params)
        end

        def user_creation_success_response
          { status: { code: 201, message: I18n.t('devise.registrations.signed_up') },
            user: @user.user_json_response }
        end

        def user_creation_error_response
          {
            status: { code: 422,
                      message: I18n.t(
                        'devise.errors.messages.not_saved',
                        count: @user.errors.count,
                        resource: @user.errors.full_messages.join(', ')
                      ) },
            errors: @user.errors.full_messages
          }
        end

        def user_params
          params.permit(:username, :email, :password, :role)
        end
      end
    end
  end
end
