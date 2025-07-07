FactoryBot.define do
  factory :request do
    user
    room_type
    checkin_date { Time.zone.today + Settings.request_checkin_days.days }
    checkout_date { Time.zone.today + Settings.request_checkout_days.days }
    quantity { Settings.request_default_quantity }
    status { Settings.request_default_status }
    token { SecureRandom.hex(Settings.request_token_length) }

    factory :pending_request do
      status { Settings.request_pending_status }
    end
  end
end
