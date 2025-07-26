# frozen_string_literal: true

# ApplicationController
class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :set_locale
  skip_before_action :verify_authenticity_token

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def success_response(resource)
    { status: { code: 200, message: I18n.t('responses.success', default: 'Success') } }.merge(resource)
  end

  def error_response(errors_array)
    { status: { code: 422, message: I18n.t('responses.error', default: 'Error') }, errors: errors_array }
  end
end
