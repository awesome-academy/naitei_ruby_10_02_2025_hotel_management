class Device < ApplicationRecord
  PERMITTED_PARAMS = %i(id name quantity _destroy).freeze
  belongs_to :room_type
  def self.ransackable_attributes _auth_object = nil
    %w(name)
  end
end
