class User::RequestsController < ApplicationController
  before_action :find_request, only: [:show, :expire, :status_check]
  before_action :find_room_type, only: :show

  def new
    assign_dates
    load_room_type_and_quantity
    calculate_total_price

    @request = Request.new(
      checkin_date: @checkin_date,
      checkout_date: @checkout_date,
      room_type_id: @room_type&.id,
      quantity: @quantity
    )
  end

  def create
    build_request_from_params

    if @request.save
      redirect_to user_request_path(@request, back_url: params[:back_url]),
                  status: :see_other,
                  flash: {success: t("request_successfull")}
    else
      flash.now[:danger] = t("request_error")
      handle_failed_create
      render :new
    end
  end

  def show
    @back_url = params[:back_url] || user_room_types_path
    return unless @request.deposited?

    redirect_to root_path,
                flash: {success: t("payment.deposit_success")}
  end

  def expire
    if @request.pending? && @request.update(status: :denied,
                                            reason: Settings.expired)
      flash[:danger] = t "payment.expired"
    end

    render json: {
      redirect: root_path,
      flash: {danger: flash[:danger]}
    }
  end

  def status_check
    if @request.deposited?
      render json: {
        deposited: true,
        redirect: root_path,
        flash: {success: t("payment.deposit_success")}
      }
    else
      render json: {deposited: false}
    end
  end

  private

  def safe_parse_date date_string
    Date.parse(date_string)
  rescue ArgumentError, TypeError
    nil
  end

  def assign_dates
    @checkin_date = safe_parse_date(params[:checkin_date]) || Time.zone.today
    @checkout_date = safe_parse_date(params[:checkout_date]) ||
                     Time.zone.today + 1.day
    @stay_duration = (@checkout_date - @checkin_date).to_i
  end

  def load_room_type_and_quantity
    @room_type = RoomType.find_by(id: params[:room_type_id])
    unless @room_type
      flash[:danger] = t("room_type.not_found")
      redirect_to user_room_types_path and return
    end

    @quantity = (params[:quantity] || 1).to_i
  end

  def calculate_total_price
    @total_price = @room_type&.price.to_f * @stay_duration * @quantity
  end

  def build_request_from_params
    @request = current_user.requests.new(
      checkin_date: safe_parse_date(params.dig(:request, :checkin_date)),
      checkout_date: safe_parse_date(params.dig(:request, :checkout_date)),
      room_type_id: params.dig(:request, :room_type_id),
      quantity: (params.dig(:request, :quantity) || 1).to_i
    )
  end

  def handle_failed_create
    @checkin_date = @request.checkin_date || Time.zone.today
    @checkout_date = @request.checkout_date || Time.zone.today + 1.day
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
