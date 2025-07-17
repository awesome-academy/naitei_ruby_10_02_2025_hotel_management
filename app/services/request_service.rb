class RequestService
  def initialize params:, user:
    @errors = []
    @user = user
    @params = params
  end

  def call
    return {errors: @errors} unless prepare_data_successfully?

    @request = Request.new(
      room_type: @room_type,
      user: @user,
      checkin_date: @checkin_date,
      checkout_date: @checkout_date,
      quantity: @quantity,
      total_price: @total_price
    )

    return {request: @request} if @request.save

    @errors.concat(@request.errors.full_messages)
    {errors: @errors}
  end

  private

  def prepare_data_successfully?
    return false unless load_room_type
    return false unless parse_and_validate_dates
    return false unless validate_quantity

    calculate_total_price
    true
  end

  def load_room_type
    @room_type = RoomType.find_by(id: @params[:room_type_id])
    unless @room_type
      @errors << Settings.messages.error.room_type_not_found
      return false
    end
    true
  end

  def parse_and_validate_dates
    @checkin_date = Date.parse(@params[:checkin_date])
    @checkout_date = Date.parse(@params[:checkout_date])

    if @checkin_date >= @checkout_date
      @errors << Settings.messages.error.checkin_after_checkout
      return false
    end
    true
  rescue ArgumentError, TypeError
    @errors << Settings.messages.error.invalid_date_format
    false
  end

  def validate_quantity
    @quantity = @params[:quantity].to_i
    if @quantity <= 0
      @errors << Settings.messages.error.invalid_quantity
      return false
    end
    true
  end

  def calculate_total_price
    @stay_duration = (@checkout_date - @checkin_date).to_i
    @total_price = @room_type.price * @stay_duration * @quantity
  end
end
