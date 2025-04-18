class User::ReviewsController < ApplicationController
  helper User::ReviewHelper

  REVIEW_PARAMS = [:score, :content].freeze

  def create
    @review = current_user.reviews.new(review_params)
    if @review.save
      flash[:success] = t("reviews.created")
    else
      flash[:danger] = t("reviews.create_failed")
    end
    redirect_to user_room_types_path
  end

  private

  def review_params
    params.require(:review).permit(*REVIEW_PARAMS)
  end
end
