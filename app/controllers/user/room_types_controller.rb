class User::RoomTypesController < ApplicationController
  def index
    @room_types = RoomType.all
    checkin_date = Date.parse(params[:checkin_date] || "2025-04-04")
    checkout_date = Date.parse(params[:checkout_date] || "2025-04-05")

    @available_rooms = {}

    @room_types.each do |room_type|
      available_rooms = available_quantity_for_range(
        room_type,
        checkin_date,
        checkout_date
      )
      @available_rooms[room_type.id] = available_rooms
    end
  end

  def show
    @room_type = RoomType.find_by(id: params[:id])
    return if @room_type.present?

    flash[:danger] = t("room_type_not_found")
    redirect_to user_room_types_path
  end

  private

  def available_quantity_for_range room_type, checkin_date, checkout_date
    total_rooms = room_type.rooms.count
    min_available = total_rooms

    (checkin_date...checkout_date).each do |date|
      booked = Request.booked_in_range(room_type.id, date).sum(:quantity)
      available = total_rooms - booked
      min_available = [min_available, available].min
    end

    min_available
  end
end
