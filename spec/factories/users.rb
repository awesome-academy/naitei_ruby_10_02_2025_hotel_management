FactoryBot.define do
    factory :user do
      sequence(:email) { |n| "test_user_#{n}@#{Settings.test_email_domain}" }
      password { Settings.default_password }
      username { Faker::Name.first_name.downcase }
      phone { "#{Settings.phone_prefix}#{Faker::Number.number(digits: Settings.phone_number_digits)}" }
      admin { false }
      activated { true }
      confirmed_at { Time.current }
    end
  end
