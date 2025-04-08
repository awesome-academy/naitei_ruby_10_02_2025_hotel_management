module ApplicationHelper
  include SessionsHelper
  include Pagy::Frontend

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "msg.please_log_in."
    redirect_to login_url
  end

  def admin_user
    redirect_to login_url unless current_user.admin?
  end

  def pagy_index index, pagy
    index + 1 + (pagy.page - 1) * pagy.limit
  end

  def sidebar_highlight_check keyword
    request.path.split("/")[3] == keyword ? "active" : ""
  end
end
