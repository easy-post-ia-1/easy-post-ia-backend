# frozen_string_literal: true

# UserAuth controlller
# Handle of the registration of the users
module Api
  module V1
    module Users
      # Controller in charge if the registration inheriting from Devise
      class RegistrationsController < Devise::RegistrationsController
        include RackSessionFix
        before_action :configure_sign_up_params, only: [:create]
        respond_to :json

        # GET /resource/sign_up
        # def new
        #   super
        # end

        # POST /resource
        def create
          super
        end

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
        def configure_sign_up_params
          devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :role, :company_id])
        end

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

        private

        def respond_with(resource, _opts = {})
          if resource.persisted?
            # Assign role if provided in params
            assign_role_to_user(resource) if params[:role].present?
            
            render json: {
              status: { code: 201, message: I18n.t('devise.registrations.signed_up') },
              user: resource.user_json_response
            }, status: :created
          else
            render json: {
              status: { code: 422,
                        message: I18n.t(
                          'devise.errors.messages.not_saved',
                          count: resource.errors.count,
                          resource: resource.errors.full_messages.join(', ')
                        ) },
              errors: resource.errors.full_messages
            }, status: :unprocessable_entity
          end
        end

        def assign_role_to_user(user)
          role_name = params[:role].downcase.to_sym
          begin
            # Ensure the role exists, create it if it doesn't
            Role.find_or_create_by(name: role_name.to_s)
            user.add_role(role_name)
          rescue => e
            Rails.logger.error "Failed to assign role #{role_name} to user #{user.id}: #{e.message}"
            # Continue without role assignment if there's an error
          end
        end
      end
    end
  end
end
