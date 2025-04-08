class SessionsController < ApplicationController
  before_action :find_user, only: [:create]
  before_action :authenticate_user, only: [:create]

  def create
    if missing_params?
      flash.now[:danger] = t("login_blank")
      render :new, status: :unprocessable_entity and return
    end

    if @user
      successful_login
    else
      failed_login
    end
  end

  def destroy
    session.delete(:user_id)
    flash[:success] = t("logout_success")
    redirect_to login_path
  end

  private

  def find_user
    @user = User.find_by(email: params[:session][:email].downcase)
  end

  def authenticate_user
    return if @user&.authenticate(params[:session][:password])

    @user = nil
  end

  def missing_params?
    params[:session][:email].blank? || params[:session][:password].blank?
  end

  def successful_login
    session[:user_id] = @user.id
    flash[:success] = t("login_success")
    forwarding_url = session[:forwarding_url]
    @user.update_last_activity
    redirect_to forwarding_url || root_path
  end

  def failed_login
    flash.now[:danger] = t("login_fail")
    render :new, status: :unprocessable_entity
  end
end
