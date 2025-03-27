class Bill < ApplicationRecord
  has_one :request, dependent: :nullify
  has_many :bills_services, dependent: :destroy
  has_many :services, through: :bills_services
end
