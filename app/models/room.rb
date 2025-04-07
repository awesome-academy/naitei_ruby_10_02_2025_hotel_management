class Room < ApplicationRecord
  belongs_to :room_type
  has_many :stay_ats, dependent: :destroy
  has_many :requests, through: :stay_ats

  def booked_days_in_month year, month
    start_of_month = Date.new(year, month, 1)
    end_of_month = start_of_month.end_of_month

    booked_days = []

    requests.where(
      "(checkin_date <= ?) AND (checkout_date >= ?)",
      end_of_month, start_of_month
    ).find_each do |request|
      (request.checkin_date...request.checkout_date).each do |date|
        booked_days << date.day if date.month == month && date.year == year
      end
    end

    booked_days.uniq.sort
  end
end
