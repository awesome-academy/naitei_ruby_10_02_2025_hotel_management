module ApplicationHelper
  include SessionsHelper

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "msg.please_log_in."
    redirect_to login_url
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
