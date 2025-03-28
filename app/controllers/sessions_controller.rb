class SessionsController < ApplicationController
  before_action :find_user, only: [:create]
  before_action :authenticate_user, only: [:create]

  def create
    if @user
      session[:user_id] = @user.id
      flash[:success] = t "login_success"
      redirect_to root_path
    else
      flash.now[:alert] = t "login_fail"
      render "new"
    end
  end

  private

  def find_user
    @user = User.find_by(email: params[:session][:email].downcase)
  end

  def authenticate_user
    return if @user&.authenticate(params[:session][:password])

    @user = nil
  end
end
