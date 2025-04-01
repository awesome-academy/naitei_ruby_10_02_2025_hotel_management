class User::RoomTypesController < ApplicationController
  def index
    @room_types = RoomType.all
  end

  def show
    @room_type = RoomType.find_by(id: params[:id])
    if @room_type.nil?
      flash[:danger] = t "room_type_not_found"
      redirect_to user_room_types_path
    end
  end
end
