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

end
