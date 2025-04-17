class DashboardController < BaseAdminController
  def index
    @user_count = User.count
    @room_count = Room.count
    @room_type_count = RoomType.count
    @bill_count = Bill.count
    @service_count = Service.count
    @request_count = Request.count
    @month = params[:month].to_i || Time.zone.today.month
    @year = params[:year].to_i || Time.zone.today.year
    @room_type_id = params[:room_type]
    @bills = Bill.paid_in_month(@month, @year)
                 .with_room_type(params[:room_type])
  end
end
