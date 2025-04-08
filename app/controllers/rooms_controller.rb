class RoomsController < BaseAdminController
  def index
    @month = params[:month]&.to_i || Time.zone.today.month
    @year = params[:year]&.to_i || Time.zone.today.year

    @day_in_month = Time.days_in_month(@month, @year)
    @room_types = RoomType.includes(:rooms)
  end
end
