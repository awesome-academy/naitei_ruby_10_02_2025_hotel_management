class AdminReviewsController < BaseAdminController
  def index
    @start_date = get_date :start_date
    @end_date = get_date :end_date
    @reviews = Review.includes(:user).from_to(@start_date, @end_date)
  end
  private
  def get_date input
    params[input].present? ? Date.parse(params[input]) : Time.zone.today
  end
end
