class Service < ApplicationRecord
  PERMITTED_PARAMS = %i(name price).freeze
  has_one_attached :image

  validates :name, presence: true,
            length: {maximum: Settings.services.name_max_length}
  validates :price, presence: true,
            numericality: {greater_than_or_equal_to: Settings.zero,
                           less_than: Settings.max_price_value}

  def self.ransackable_attributes _auth_object = nil
    %w(name price)
  end

  def self.ransackable_associations _auth_object = nil
    []
  end
end
