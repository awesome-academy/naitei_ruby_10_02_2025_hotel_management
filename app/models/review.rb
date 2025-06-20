class Review < ApplicationRecord
  belongs_to :user

  validates :content, presence: true
  scope :by_date_range, lambda {|start_date, end_date|
    where(created_at: start_date.beginning_of_day..end_date.end_of_day)
  }
  def self.ransackable_attributes _auth_object = nil
    %w(content created_at score)
  end
end
