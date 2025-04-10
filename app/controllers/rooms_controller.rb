class RoomsController < BaseAdminController
  before_action :get_room, only: %i(show destroy)

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

  def show; end

  def destroy
    unless @room.modifiable?
      flash[:error] = t "msg.room_has_upcoming_bookings"
      return redirect_to rooms_path
    end

    if @room.destroy
      flash[:success] = t "msg.room_deleted"
      redirect_to rooms_path
    else
      flash[:error] = t "msg.room_deleted_failed"
      redirect_to rooms_path, status: :unprocessable_entity
    end
  end

  private
  def room_params
    params.require(:room).permit(Room::PERMITTED_PARAMS)
  end

  def get_room
    @room = Room.find_by id: params[:id]
    return if @room

    flash[:error] = t "msg.room_not_found"
    redirect_to rooms_path
  end
end
