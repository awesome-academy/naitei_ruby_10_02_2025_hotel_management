class RoomType < ApplicationRecord
  PERMITTED_PARAMS = %i(name description price view).freeze + [{images: []},
  {devices_attributes: Device::PERMITTED_PARAMS}].freeze

  has_many :rooms, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :requests_room_types, dependent: :destroy
  has_many :requests, through: :requests_room_types
  has_many_attached :images
  accepts_nested_attributes_for :devices, allow_destroy: true
end
