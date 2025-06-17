class User::ReviewsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :review, through: :current_user
  helper User::ReviewHelper

  REVIEW_PARAMS = [:score, :content].freeze

  def create
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
