module RequestsHelper
  def get_redirect_path request
    return checkin_request_path(request) if request.deposited?

    return checkout_request_path(request) if request.checkined?

    request_path(request)
  end
end
