class Room < ApplicationRecord
  belongs_to :room_type
  has_many :stay_ats, dependent: :destroy
  has_many :request, through: :stay_ats
end
