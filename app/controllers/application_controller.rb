class ApplicationController < ActionController::Base
  before_action :set_locale
  include Pagy::Backend
  include DeviseHelper
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def require_login
    return if user_signed_in?

    flash[:danger] = t("user.please_login")
    redirect_to login_path
  end
end
