class Request < ApplicationRecord
  before_save :set_deposit_amount_if_deposited
  enum status: {pending: 0, deposited: 1, checkined: 2, checkouted: 3,
                finished: 4, denied: 5}

  belongs_to :user
  belongs_to :room_type

  has_many :stay_ats, dependent: :destroy
  has_many :rooms, through: :stay_ats
  has_one :bill, dependent: :destroy

  validates :reason, presence: true, if: :denied?
  validates :checkin_date, :checkout_date, :room_type_id, :quantity,
            presence: true

  scope :with_room_type, (lambda do |room_type_id|
    where(room_type_id: room_type_id)
  end)

  scope :active_statuses, (lambda do
    where(status: %i(deposited checkined finished))
  end)

  scope :overlapping_date, lambda {|date|
    where("checkin_date <= ? AND checkout_date > ?", date, date)
  }

  scope :booked_in_range, lambda {|room_type_id, date|
    with_room_type(room_type_id).active_statuses.overlapping_date(date)
  }

  private

  def set_deposit_amount_if_deposited
    self.deposit_amount = deposited? ? total_price.to_f * 0.5 : 0
  def room_total_price
    quantity * room_type.price * (checkout_date - checkin_date).to_i
  end
end
