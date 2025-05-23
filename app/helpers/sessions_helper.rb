module SessionsHelper
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
