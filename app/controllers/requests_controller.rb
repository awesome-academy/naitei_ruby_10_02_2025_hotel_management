class RequestsController < BaseAdminController
  before_action :get_request, except: %i(index)
  def index
    @requests = Request.includes(:user, :room_type)
  end

  def checkin
    room_type = @request.room_type
    @avaiable_rooms = room_type.get_available_rooms(@request.checkin_date,
                                                    @request.checkout_date)
    @avaiable_rooms.uniq!
    render "checkin"
  end

  def checkin_submit
    selected_room_ids = params[:room_ids]

    return unless checkin_room_selected? selected_room_ids
    return unless check_checkin_amount? selected_room_ids.size
    return invalid_request_status unless invalid_checkin_status

    selected_room_ids.each do |id|
      StayAt.create!(request_id: @request.id, room_id: id)
    end

    @request.update(status: :checkined)
    flash[:success] = t "msg.request_checkined"
    redirect_to :requests
  end

  def deny
    respond_to do |format|
      format.html{redirect_to :checkin_request}
      format.turbo_stream
    end
  end

  def deny_submit
    if @request.update(status: Settings.requests.status.denied,
                       reason: params[:reason])
      flash[:success] = t "msg.request_denied"
      redirect_to :requests
    else
      flash[:error] = t "msg.deny_failed"
      redirect_to :checkin_request
    end
  end

  private
  def get_request
    @request = Request.includes(:user, :room_type)
                      .find_by id: params[:id]
    return if @request

    flash[:error] = t "msg.invalid_request"
    redirect_to requests_path
  end

  def invalid_request_status
    flash[:error] = t "msg.invalid_request_status"
    redirect_to :checkin_request
  end

  def invalid_checkin_status
    @request.status == Settings.requests.status.deposited
  end

  def check_checkin_amount? room_count
    return true unless room_count != @request.quantity

    flash[:error] = t "msg.invalid_room_selected"
    redirect_to :checkin_request
    false
  end

  def checkin_room_selected? selected_room_ids
    return true unless selected_room_ids.blank? || selected_room_ids.nil?

    flash[:error] = t "msg.no_room_selected"
    redirect_to :checkin_request
    false
  end
end
