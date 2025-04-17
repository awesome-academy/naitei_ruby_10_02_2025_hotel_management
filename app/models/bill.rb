class Bill < ApplicationRecord
  PERMITTED_PARAMS = %i(service_id quanity _destroy).freeze

  has_one :request, dependent: :nullify
  has_many :bills_services, dependent: :destroy
  has_many :services, through: :bills_services
  belongs_to :user

  accepts_nested_attributes_for :bills_services, allow_destroy: true

  scope :paid_in_month, lambda {|month, year|
    if month.present? && year.present?
      where(pay_at: Date.new(year, month, 1)..Date.new(year, month, -1))
    end
  }

  scope :with_room_type, lambda {|room_type_id|
    if room_type_id.present?
      joins("INNER JOIN requests ON requests.id = bills.request_id")
        .where(requests: {room_type_id: room_type_id})
    end
  }

  def status
    pay_at.present? ? :paid : :unpay
  end
end
