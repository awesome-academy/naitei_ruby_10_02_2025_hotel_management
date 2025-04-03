class Device < ApplicationRecord
  PERMITTED_PARAMS = %i(id name quantity _destroy).freeze
  belongs_to :room_type
end
