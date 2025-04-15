class Bill < ApplicationRecord
  PERMITTED_PARAMS = %i(service_id quanity _destroy).freeze

  has_one :request, dependent: :nullify
  has_many :bills_services, dependent: :destroy
  has_many :services, through: :bills_services
  belongs_to :user

  accepts_nested_attributes_for :bills_services, allow_destroy: true
end
