class RoomsController < BaseAdminController
  include ApplicationHelper
  before_action :logged_in_user
  before_action :admin_user

  def index
    @month = params[:month]&.to_i || Time.zone.today.month
    @year = params[:year]&.to_i || Time.zone.today.year

    @day_in_month = Time.days_in_month(@month, @year)
    @room_types = RoomType.includes(:rooms)
  end

  def new
    @room = Room.new
  end

  def create
    @room = Room.new room_params
    if @room.save
      flash[:success] = t "msg.room_created"
      redirect_to rooms_path
    else
      flash.now[:error] = t "msg.room_created_failed"
      render :new, status: :unprocessable_entity
    end
  end

  private
  def room_params
    params.require(:room).permit(Room::PERMITTED_PARAMS)
  end
end
