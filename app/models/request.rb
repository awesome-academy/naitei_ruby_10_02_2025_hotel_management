class Request < ApplicationRecord
  enum status: {pending: 0, deposited: 1, checkined: 2, finished: 3,
                denied: 4}

  belongs_to :user
  belongs_to :room_type

  has_many :stay_ats, dependent: :destroy
  has_many :rooms, through: :stay_ats
  has_one :bill, dependent: :destroy

  validates :reason, presence: true, if: :denied?
  validates :checkin_date, :checkout_date, :room_type_id, :quantity,
            presence: true

  scope :with_room_type, lambda {|room_type_id|
    where(room_type_id: room_type_id)
  }

  scope :active_statuses, ->{where(status: %i(deposited checkined finished))}
  scope :overlapping_date, lambda {|date|
    where("checkin_date <= ? AND checkout_date > ?", date, date)
  }

  scope :booked_in_range, lambda {|room_type_id, date|
    with_room_type(room_type_id).active_statuses.overlapping_date(date)
  }
end
