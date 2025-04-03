class RequestsRoomType < ApplicationRecord
  belongs_to :request
  belongs_to :room_type

  validates :quantity, presence: true,
                       numericality: {greater_than_or_equal_to: 0}
end
