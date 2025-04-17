class Review < ApplicationRecord
  belongs_to :user

  validates :content, presence: true
  scope :from_to, lambda {|start_date, end_date|
    if start_date.present? && end_date.present?
      where(created_at: start_date.beginning_of_day..end_date.end_of_day)
    end
  }
end
