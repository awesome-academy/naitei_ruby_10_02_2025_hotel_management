class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable

  PERMITTED_ATTRS = %i(usename email phone password
password_confirmation).freeze
  PERMITTED_UPDATE_ATTRS = (PERMITTED_ATTRS + [:current_password]).freeze
  before_create :set_last_activity

  has_many :reviews, dependent: :destroy
  has_many :requests, dependent: :destroy

  validates :email, presence: true,
                    length: {maximum: Settings.user_email_max_length},
                    format: {with: Settings.valid_email_regex},
                    uniqueness: {case_sensitive: false}
  validates :phone, presence: true,
                    length: {is: Settings.phone_length},
                    format: {with: Settings.valid_phone_regex}
  validates :usename,  presence: true,
                    length: {maximum: Settings.user_name_max_length}
  validates :password, presence: true,
                       length: {minimum: Settings.user_password_min_length},
                       allow_nil: true
  def self.ransackable_attributes _auth_object = nil
    %w(usename email phone admin activated)
  end

  def self.ransackable_associations _auth_object = nil
    %w(requests reviews)
  end

  def update_last_activity
    update(last_activity: Time.current)
  end

  def role
    admin ? :admin : :user
  end

  def status
    activated ? :activated : :deactivated
  end

  def activate
    update(activated: true)
  end

  def deactivate
    update(activated: false)
  end

  private
  def set_last_activity
    self.last_activity = Time.current
  end
end
