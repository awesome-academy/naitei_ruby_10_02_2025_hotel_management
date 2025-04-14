class User::RequestsController < ApplicationController
  before_action :find_request, only: %i(show expire status_check)
  before_action :find_room_type, only: :show

  def new
    prepare_request_data

    @request = Request.new(
      checkin_date: @checkin_date,
      checkout_date: @checkout_date,
      room_type_id: @room_type&.id,
      quantity: @quantity
    )
  end

  def index
    @pagy, @requests = pagy(
      current_user.requests.order(created_at: :desc),
      limit: Settings.requests.limit
    )
  end

  def create
    prepare_request_data

    @request = build_request

    if @request.save
      redirect_to_success
    else
      flash.now[:danger] = t("request_error")
      handle_failed_create
      render :new
    end
  end

  def show
    @back_url = params[:back_url] || user_room_types_path
    return unless @request.deposited?

    redirect_to root_path, flash: {success: t("payment.deposit_success")}
  end

  def expire
    if @request.pending? && @request.update(status: :denied,
                                            reason: Settings.expired)
      flash[:danger] = t("payment.expired")
    end

    render json: {
      redirect: user_requests_path,
      flash: {danger: flash[:danger]}
    }
  end

  def status_check
    if @request.deposited?
      render json: {
        deposited: true,
        redirect: user_requests_path,
        flash: {success: t("payment.deposit_success")}
      }
    else
      render json: {deposited: false}
    end
  end

  private

  def prepare_request_data
    assign_dates
    load_room_type_and_quantity
    calculate_total_price
  end

  def safe_parse_date date_string
    Date.parse(date_string)
  rescue ArgumentError, TypeError
    nil
  end

  def assign_dates
    source = params[:request] || params
    @checkin_date = safe_parse_date(source[:checkin_date]) || Time.zone.today
    @checkout_date =
      safe_parse_date(source[:checkout_date]) || Time.zone.today + 1.day
    @stay_duration = (@checkout_date - @checkin_date).to_i
  end

  def load_room_type_and_quantity
    source = params[:request] || params
    @room_type = RoomType.find_by(id: source[:room_type_id])

    unless @room_type
      flash[:danger] = t("room_type.not_found")
      redirect_to user_room_types_path and return
    end

    @quantity = (source[:quantity] || 1).to_i
  end

  def calculate_total_price
    return unless @room_type&.price && @stay_duration && @quantity

    @total_price = @room_type.price.to_f * @stay_duration * @quantity
  end

  def build_request
    current_user.requests.new(
      checkin_date: @checkin_date,
      checkout_date: @checkout_date,
      room_type_id: @room_type&.id,
      quantity: @quantity,
      total_price: @total_price
    )
  end

  def redirect_to_success
    redirect_to user_request_path(@request, back_url: params[:back_url]),
                status: :see_other,
                flash: {success: t("request_successfull")}
  end

  def handle_failed_create
    @checkin_date = @request.checkin_date || Time.zone.today
    @checkout_date =
      safe_parse_date(source[:checkout_date]) || Time.zone.today + 1.day

    @stay_duration = (@checkout_date - @checkin_date).to_i
    @room_type = @request.room_type
    @quantity = @request.quantity || 1
    calculate_total_price
  end

  def find_request
    @request = Request.find_by(id: params[:id])
    return if @request

    flash[:danger] = t("request.not_found")
    redirect_to root_path
  end

  def find_room_type
    @room_type = RoomType.find_by(id: @request.room_type_id)
    return if @room_type

    flash[:danger] = t("room_type.not_found")
    redirect_to user_room_types_path
  end
end
