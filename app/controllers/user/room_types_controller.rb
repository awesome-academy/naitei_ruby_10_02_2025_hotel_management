class User::RoomTypesController < ApplicationController
  def index
    @q = RoomType.ransack(build_ransack_params)
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
    @q = RoomType.ransack(build_ransack_params)
    @room_types = @q.result(distinct: true)
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
    unless params[:checkin_date].present? || params[:checkout_date].present?
      return true
    end

    parse_dates
    return false if @date_error_message

    validate_dates
  end

  def parse_dates
    @checkin_date = parse_date(params[:checkin_date])
    @checkout_date = parse_date(params[:checkout_date])
  rescue ArgumentError
    @date_error_message = t("errors.invalid_date_format")
  end

  def parse_date date_param
    date_param.present? ? Date.parse(date_param) : nil
  end

  def validate_dates
    unless @checkin_date && @checkout_date
      @date_error_message = t("errors.dates_required")
      return false
    end

    if @checkin_date < Time.zone.today
      @date_error_message = t("errors.checkin_date_in_past")
      return false
    end

    if @checkout_date <= @checkin_date
      @date_error_message = t("errors.checkout_date_invalid")
      return false
    end

    true
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

  def build_ransack_params
    params[:q] ||= {}
    search_params = params[:q].dup
    if search_params[:search_type].present? &&
       search_params[:search_value].present?
      search_params[search_params[:search_type]] =
        search_params.delete(:search_value)
      search_params.delete(:search_type)
    elsif search_params[:search_value].present?
      search_params[:name_cont] = search_params.delete(:search_value)
    end
    search_params
  end
end
