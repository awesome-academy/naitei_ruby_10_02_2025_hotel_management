class RoomType < ApplicationRecord
  acts_as_paranoid
  PERMITTED_PARAMS = %i(name description price view).freeze + [{images: []},
  {devices_attributes: Device::PERMITTED_PARAMS}].freeze

  has_many :rooms, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :requests_room_types, dependent: :destroy
  has_many :requests, through: :requests_room_types
  has_many_attached :images
  accepts_nested_attributes_for :devices, allow_destroy: true

  validates :name, presence: true, length: {maximum: Settings.digit_50}
  validates :images, content_type: {in: Settings.allowed_image_file_type,
                                    message: I18n.t("msg.invalid_image_format")}
  validates :description, length: {maximum: Settings.digit_500}
  validates :price, presence: true, numericality:
            {greater_than_or_equal_to: Settings.zero,
             less_than: Settings.max_price_value}

  def get_avaliable_room checkin_date, checkout_date
    all_rooms = rooms
    avaiable_rooms = all_rooms

    (checkin_date...checkout_date).each do |date|
      requests = Request.where("requests.checkin_date <= ?
                                AND requests.checkout_date > ?",
                               date, date)
      booked_rooms = []
      requests.each do |request|
        booked_rooms += request.rooms
      end
      booked_rooms.uniq!
      avaiable_rooms -= booked_rooms
    end
    avaiable_rooms
  end
end
