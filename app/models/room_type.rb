class RoomType < ApplicationRecord
  has_many :rooms, dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :requests_room_types, dependent: :destroy
  has_many :requests, through: :requests_room_types
  has_many_attached :images
end
