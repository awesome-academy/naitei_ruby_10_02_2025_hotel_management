module ApplicationHelper
  include Pagy::Frontend
  def admin_user
    redirect_to new_user_session_path unless current_user.admin?
  end

  def pagy_index index, pagy
    index + 1 + (pagy.page - 1) * pagy.limit
  end

  def sidebar_highlight_check keyword
    request.path.split("/")[3] == keyword ? "active" : ""
  end
end
