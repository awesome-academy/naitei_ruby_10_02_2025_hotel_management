class User < ApplicationRecord
  has_many :reviews, dependent: :destroy
  has_many :requests, dependent: :destroy

  validates :email, presence: true,
                    length: {maximum: Settings.user_email_max_length},
                    format: {with: Settings.valid_email_regex},
                    uniqueness: {case_sensitive: false}
  validates :phone, presence: true,
                    length: {is: Settings.phone_length},
                    format: {with: Settings.valid_phone_regex}
  validates :name,  presence: true,
                    length: {maximum: Settings.user_name_max_length}
  validates :password, presence: true,
                       length: {minimum: Settings.user_password_min_length},
                       allow_nil: true

  has_secure_password
end
