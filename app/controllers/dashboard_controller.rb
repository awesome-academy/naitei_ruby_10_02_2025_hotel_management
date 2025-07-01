class DashboardController < BaseAdminController
  before_action :load_counts, only: :index
  before_action :set_date_params, only: :index
  def index
    @bills = Bill.paid_in_month(@month, @year)
                 .with_room_type(params[:room_type])
  end

  def send_revenue_report
    SendRevenueReportJob.perform_later(@month, @year)
    flash[:success] = t("dashboard.revenue_report_sent")
    redirect_to dashboard_path
  end

  private
  def load_counts
    @user_count = User.count
    @room_count = Room.count
    @room_type_count = RoomType.count
    @bill_count = Bill.count
    @service_count = Service.count
    @request_count = Request.count
  end

  def set_date_params
    @month = params[:month].blank? ? Time.zone.today.month : params[:month].to_i
    @year = params[:year].blank? ? Time.zone.today.year : params[:year].to_i
  end
end
