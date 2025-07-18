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
  validates :images, content_type: {
    in: Settings.allowed_image_file_type,
    message: I18n.t("msg.invalid_image_format")
  }
  validates :description, length: {maximum: Settings.digit_500}
  validates :price, presence: true, numericality: {
    greater_than_or_equal_to: Settings.zero,
    less_than: Settings.max_price_value
  }
  def self.ransackable_attributes _auth_object = nil
    %w(name description view)
  end

  def self.ransackable_associations _auth_object = nil
    %w(devices)
  end

  def available_rooms checkin_date, checkout_date
    return 0 unless checkin_date.present? && checkout_date.present?

    total_rooms = rooms.count
    min_available = total_rooms

    (checkin_date...checkout_date).each do |date|
      booked = Request.booked_in_range(id, date).sum(:quantity)
      available = total_rooms - booked
      min_available = [min_available, available].min
    end

    min_available
  end

  def get_available_rooms checkin_date, checkout_date
    booked_rooms = (checkin_date...checkout_date).flat_map do |date|
      Request.overlapping_date(date).flat_map(&:rooms)
    end.uniq
    rooms - booked_rooms
  end
end
