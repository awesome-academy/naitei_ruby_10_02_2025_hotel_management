class RequestsController < BaseAdminController
  before_action :get_request, except: %i(index)
  before_action :check_checkinable, only: %i(checkin checkin_submit)
  before_action :check_checkoutable, only: %i(checkout checkout_submit)
  before_action :check_payable_request, only: %i(bill_pay)

  def index
    @pagy, @requests = pagy Request.includes(:user, :room_type).newest,
                            limit: Settings.services.items_per_page
  end

  def show; end

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

    selected_room_ids.each do |id|
      StayAt.create!(request_id: @request.id, room_id: id)
    end

    @request.update(status: :checkined)
    @request.send_request_checkined_mail
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
      @request.send_request_denied_mail
      flash[:success] = t "msg.request_denied"
      redirect_to :requests
    else
      flash[:error] = t "msg.deny_failed"
      redirect_to :checkin_request
    end
  end

  def checkout
    @bill = @request.build_bill
    @bill.bills_services.build
  end

  def checkout_submit
    services_fields = bill_params[:bills_services_attributes].values
    @bill = @request.build_bill(
      user: @request.user,
      total: calculate_total(services_fields),
      bills_services_attributes: services_fields.reject do |s|
        s[:service_id].blank?
      end
    )
    if @bill.save
      on_checkout_success
    else
      flash[:error] = t "msg.checkout_failed"
      render :checkout
    end
  end

  def bill_pay
    @request.bill.pay_at = Time.zone.now
    if @request.bill.save
      @request.update(status: Settings.requests.status.finished)
      flash[:success] = t "msg.bill_paid"
    else
      flash[:error] = t "msg.bill_pay_failed"
    end
    redirect_to :requests
  end

  private
  def bill_params
    params.require(:bill).permit(
      bills_services_attributes: Bill::PERMITTED_PARAMS
    )
  end

  def get_request
    @request = Request.includes(:user, :room_type)
                      .find_by id: params[:id]
    return if @request

    flash[:error] = t "msg.invalid_request"
    redirect_to requests_path
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

  def check_checkinable
    return if @request.deposited?

    flash[:error] = t "msg.invalid_request_status"
    redirect_to requests_path
  end

  def check_checkoutable
    return if @request.checkined?

    flash[:error] = t "msg.invalid_request_status"
    redirect_to requests_path
  end

  def check_payable_request
    return if @request.checkouted?

    flash[:error] = t "msg.invalid_request_status"
    redirect_to requests_path
  end

  def calculate_total services_fields
    services = Service.where(id: services_fields.map{|s| s[:service_id]})
    service_total = services_fields.sum do |sf|
      service = services.find_by id: sf[:service_id]
      next 0 unless service

      service.price * sf[:quanity].to_i
    end
    service_total + @request.room_total_price
  end

  def on_checkout_success
    flash[:success] = t "msg.checkout_success"
    @request.update(status: Settings.requests.status.checkouted)
    redirect_to :requests
  end
end
