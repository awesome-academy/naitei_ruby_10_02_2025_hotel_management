class RequestsController < BaseAdminController
  include ApplicationHelper
  before_action :logged_in_user
  before_action :admin_user
  before_action :get_request, only: %i(checkin checkin_submit)
  def index
    @requests = Request.includes(:user, requests_room_types: :room_type)
  end

  def checkin
    room_types = @request.room_types
    @avaiable_rooms = []
    room_types.each do |room_type|
      @avaiable_rooms += room_type.get_avaliable_room(@request.checkin_date,
                                                      @request.checkout_date)
    end
    @avaiable_rooms.uniq!
    render "checkin"
  end

  def checkin_submit
    selected_room_ids = params[:room_ids]

    return invalid_request_status unless invalid_checkin_status

    if selected_room_ids.blank? || selected_room_ids.nil?
      flash[:error] = t "msg.no_room_selected"
      return redirect_to :checkin_request
    end

    selected_room_ids.each do |id|
      StayAt.create!(request_id: @request.id, room_id: id)
    end

    @request.update(status: :checkined)
    flash[:success] = t "msg.request_checkined"
    redirect_to :requests
  end

  private
  def get_request
    @request = Request.includes(:user, requests_room_types: :room_type)
                      .find params[:id]
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
end
