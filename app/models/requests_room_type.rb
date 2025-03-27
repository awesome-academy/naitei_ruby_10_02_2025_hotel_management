class RequestsRoomType < ApplicationRecord
  belongs_to :request
  belongs_to :room_type
end
