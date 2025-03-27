class StayAt < ApplicationRecord
  belongs_to :request
  belongs_to :room
end
