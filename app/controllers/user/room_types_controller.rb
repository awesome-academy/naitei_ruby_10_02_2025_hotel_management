class User::RoomTypesController < ApplicationController
  def index
    assign_room_types
    assign_reviews
    assign_dates
    assign_available_rooms
  end

  def show
    @room_type = RoomType.find_by(id: params[:id])

    return if @room_type

    flash[:danger] = t("room_type_not_found")
    redirect_to user_room_types_path
  end

  private

  def assign_room_types
    @room_types = RoomType.all
  end

  def assign_reviews
    @pagy, @reviews = pagy(
      Review.order(created_at: :desc),
      limit: Settings.limit
    )
    @review = Review.new
    @average_score = @reviews.average(:score) || 0
    @star_counts = Review.group(:score).count
  end

  def assign_dates
    if params[:checkin_date].present?
      @checkin_date = Date.parse(params[:checkin_date])
    end
    return if params[:checkout_date].blank?

    @checkout_date = Date.parse(params[:checkout_date])
  end

  def assign_available_rooms
    @available_rooms = {}

    @room_types.each do |room_type|
      available_rooms = available_quantity_for_range(room_type, @checkin_date,
                                                     @checkout_date)
      @available_rooms[room_type.id] = available_rooms
    end
  end

  def available_quantity_for_range room_type, checkin_date, checkout_date
    return 0 unless checkin_date.present? && checkout_date.present?

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
