class RoomTypesController < ApplicationController
  layout "admin"

  def index
    @room_types = RoomType.all
  end

  def new
    @room_type = RoomType.new
    @room_type.devices.build
  end

  def create
    @room_type = RoomType.new(room_type_params)
    if @room_type.save
      flash[:success] = t "msg.room_type_created"
      redirect_to room_types_path
    else
      @room_type.devices.build if @room_type.devices.empty?
      render :new, status: :unprocessable_entity
    end
  end

  private
  def room_type_params
    params.require(:room_type).permit(*RoomType::PERMITTED_PARAMS)
  end
end
