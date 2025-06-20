class UsersController < BaseAdminController
  load_and_authorize_resource
  def index
    @q = User.ransack(params[:q])
    @pagy, @users = pagy(@q.result(disinct: true),
                         limit: Settings.users.items_per_page)
  end

  def show; end

  def activate
    if @user.activate
      flash[:success] = t "msg.user_activated"
    else
      flash[:error] = t "msg.user_activate_failed"
    end
    redirect_to users_path
  end

  def deactivate
    if @user.deactivate
      flash[:success] = t "msg.user_deactivated"
    else
      flash[:error] = t "msg.user_deactivate_failed"
    end
    redirect_to users_path
  end
end
