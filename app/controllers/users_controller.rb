class UsersController < BaseAdminController
  before_action :get_user, except: %i(index)

  def index
    @pagy, @users = pagy User.search_by_all(params[:search])
                             .filter_by_role(params[:admin])
                             .filter_by_status(params[:status]),
                         limit: Settings.users.items_per_page
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

  private
  def get_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:error] = t "msg.user_not_found"
    redirect_to users_path
  end
end
