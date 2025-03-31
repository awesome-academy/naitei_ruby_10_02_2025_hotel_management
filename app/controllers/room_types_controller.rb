class RoomTypesController < ApplicationController
  include ApplicationHelper
  layout "admin"
  before_action :logged_in_user
  before_action :admin_user, only: %i(create destroy)
  before_action :get_room_type, only: %i(show destroy)

  def index
    @room_types = RoomType.without_deleted
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

  def show; end

  def destroy
    if @room_type.destroy
      flash[:success] = t "msg.room_type_deleted"
    else
      flash[:danger] = t "msg.delete_fail"
    end
    redirect_to room_types_url
  end

  private
  def room_type_params
    params.require(:room_type).permit(*RoomType::PERMITTED_PARAMS)
  end

  def get_room_type
    @room_type = RoomType.find_by id: params[:id]
    return if @room_type

    flash[:error] = t "msg.invalid_room_type"
    redirect_to room_types_path
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end
end
