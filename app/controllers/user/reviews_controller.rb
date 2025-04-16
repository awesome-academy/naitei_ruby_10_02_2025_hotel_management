class User::ReviewsController < ApplicationController
  helper User::ReviewHelper

  REVIEW_PARAMS = [:score, :content].freeze

  def create
    @review = current_user.reviews.new(review_params)
    if @review.save
      redirect_to user_room_types_path, notice: t("reviews.created")
    else
      redirect_to user_room_types_path, alert: t("reviews.create_failed")
    end
  end

  private

  def review_params
    params.require(:review).permit(*REVIEW_PARAMS)
  end
end
