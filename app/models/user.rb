class User < ApplicationRecord
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

  scope :search_by_all, lambda {|search|
    where("email LIKE :q OR usename LIKE :q OR phone LIKE :q", q: "%#{search}%")
  }
  scope :filter_by_role, lambda {|admin|
    if admin.present?
      where("admin = ?", ActiveModel::Type::Boolean.new.cast(admin))
    end
  }
  scope :filter_by_status, lambda {|status|
    if status.present?
      where("activated = ?", ActiveModel::Type::Boolean.new.cast(status))
    end
  }

  has_secure_password

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
