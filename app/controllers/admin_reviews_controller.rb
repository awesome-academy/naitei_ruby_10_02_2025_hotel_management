class AdminReviewsController < BaseAdminController
  def index
    @q = Review.ransack(params[:q])
    @start_date = get_date :start_date
    @end_date = get_date :end_date
    @reviews = @q.result(distinct: true)
                 .by_date_range(@start_date,
                                @end_date)
    @pagy, @reviews = pagy(@reviews, limit: Settings.reviews.items_per_page)
  end
  private
  def get_date input
    params[input].present? ? Date.parse(params[input]) : Time.zone.today
  end
end
