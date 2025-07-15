class ApplicationController < ActionController::Base
  before_action :set_locale, unless: :api_request
  before_action :initialize_search
  include Pagy::Backend
  include DeviseHelper
  include CanCan::ControllerAdditions
  rescue_from CanCan::AccessDenied do |_exception|
    if user_signed_in?
      redirect_to root_path
      flash[:danger] = t("access_denied")
    else
      flash[:danger] = t("please_login")
      redirect_to new_user_session_path

    end
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  private

  def initialize_search
    @q = RoomType.ransack(params[:q])
  end

  def api_request
    request.path.start_with?("/api")
  end
end
