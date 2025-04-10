class Service < ApplicationRecord
  PERMITTED_PARAMS = %i(name price).freeze
  has_one_attached :image

  validates :name, presence: true,
            length: {maximum: Settings.services.name_max_length}
  validates :price, presence: true,
            numericality: {greater_than_or_equal_to: Settings.zero,
                           less_than: Settings.max_price_value}

  scope :searched, ->(search){where("name LIKE ?", "%#{search}%")}
end
