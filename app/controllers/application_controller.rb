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
end
