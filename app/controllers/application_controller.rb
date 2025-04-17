class ApplicationController < ActionController::Base
  before_action :set_locale
  helper_method :current_user
  include Pagy::Backend
  include SessionsHelper
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    return if current_user

    redirect_to login_path
  end
end
