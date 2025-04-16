module User::ReviewHelper
  def average_review_score reviews
    (reviews.average(:score) || 0).round(1)
  end
end
