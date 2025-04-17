module AdminReviewsHelper
  def render_review_stars score
    full_stars = "★" * score.to_i
    empty_stars = "☆" * (5 - score.to_i)
    content_tag(:div, full_stars + empty_stars, class: "review-score")
  end
end
