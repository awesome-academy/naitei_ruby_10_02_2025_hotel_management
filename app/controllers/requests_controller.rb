class RequestsController < BaseAdminController
  include ApplicationHelper
  before_action :logged_in_user
  before_action :admin_user
  def index
    @requests = Request.includes(:user, requests_room_types: :room_type)
  end
end
